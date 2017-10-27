//
//  Tin.swift
//  Uridium
//
//  Created by renan jegouzo on 12/10/2017.
//  Copyright © 2017 aestesis. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Vulkan
import Foundation

public class Tin {
    public class TinNode {
        let ll:LunarLayer
        let engine:Tin
        init?(engine:Tin) {
            self.ll = engine.ll
            self.engine = engine
        }
    }
    public class Device {
        public struct MemoryProperties {
            public var types:[VkMemoryType]
            public var heaps:[VkMemoryHeap]
            public init() {
                types = [VkMemoryType]()
                heaps = [VkMemoryHeap]()
            }
        }
        var ll : LunarLayer
        public var physicalDevice:VkPhysicalDevice
        public var apiVersion:Int
        public var driverVersion:Int
        public var vendorID:Int
        public var deviceID:Int
        public var deviceType:VkPhysicalDeviceType
        public var deviceName:String
        public var limits:VkPhysicalDeviceLimits
        public var sparseProperties:VkPhysicalDeviceSparseProperties
        public var queuesProperties = [VkQueueFamilyProperties]()
        public var memoryProperties = MemoryProperties()
        init(ll:LunarLayer,device:VkPhysicalDevice, properties p:VkPhysicalDeviceProperties) {
            self.ll = ll
            self.physicalDevice = device
            self.apiVersion = Int(p.apiVersion)
            self.driverVersion = Int(p.driverVersion)
            self.vendorID = Int(p.vendorID)
            self.deviceID = Int(p.deviceID)
            self.deviceType = p.deviceType
            var name = p.deviceName
            let count = Int(VK_MAX_PHYSICAL_DEVICE_NAME_SIZE)
            let ptr = UnsafeMutableRawPointer(&name).bindMemory(to:Int8.self,capacity:count)
            let ar = Array(UnsafeBufferPointer(start:ptr,count:count))
            self.deviceName = String(cString:ar)
            self.limits = p.limits
            self.sparseProperties = p.sparseProperties
            self.enumerateQueues()
            self.enumerateMemoryProperties()
        }
        func enumerateQueues() {
            var count : UInt32 = 0
            ll.vkGetPhysicalDeviceQueueFamilyProperties!(physicalDevice, &count, nil)
            queuesProperties = [VkQueueFamilyProperties] (repeating:VkQueueFamilyProperties(), count:Int(count))
            ll.vkGetPhysicalDeviceQueueFamilyProperties!(physicalDevice, &count, &queuesProperties)
            for i in 0..<Int(count) {
                let fp = queuesProperties[i]
                var operation = ""
                if fp.queueFlags & VK_QUEUE_GRAPHICS_BIT.rawValue != 0 {
                    operation += "graphics "
                }
                if fp.queueFlags & VK_QUEUE_COMPUTE_BIT.rawValue != 0 {
                    operation += "compute "
                }
                if fp.queueFlags & VK_QUEUE_TRANSFER_BIT.rawValue != 0 {
                    operation += "transfer "
                }
                if fp.queueFlags & VK_QUEUE_SPARSE_BINDING_BIT.rawValue != 0 {
                    operation += "sparse "
                }
                NSLog("urdidium: device \(deviceName) queue \(i) \(operation)")
            }
        }
        func enumerateMemoryProperties() {
            var p = VkPhysicalDeviceMemoryProperties()
            ll.vkGetPhysicalDeviceMemoryProperties!(physicalDevice, &p)
            iterate(p.memoryTypes) { i,v in
                if i<p.memoryTypeCount, let mt = v as? VkMemoryType {
                    memoryProperties.types.append(mt)
                }
            }
            iterate(p.memoryHeaps) { i,v in
                if i<p.memoryHeapCount, let mh = v as? VkMemoryHeap {
                    memoryProperties.heaps.append(mh)
                }
            }
        }
        func memoryTypeIndex(typeBits:UInt32, requirements:VkFlags) -> UInt32? {
            var tb = typeBits
            var i = 0
            for mt in memoryProperties.types {
                if (tb & 1) == 1 {
                    if (mt.propertyFlags & requirements) == requirements {
                        return UInt32(i)
                    }
                }
                tb >>= 1
                i += 1
            }
            return nil;
        }
    }
    public class CommandBuffer : TinNode {
        var cb:VkCommandBuffer?
        public override init?(engine:Tin) {
            super.init(engine:engine)
            var setupBufferInfo = VkCommandBufferAllocateInfo()
            setupBufferInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
            setupBufferInfo.commandPool = engine.commandPool
            setupBufferInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
            setupBufferInfo.commandBufferCount = 1
            if ll.vkAllocateCommandBuffers!(engine.logicalDevice, &setupBufferInfo, &cb) != VK_SUCCESS {
                return nil
            }
            var commandBufferBeginInfo = VkCommandBufferBeginInfo()
            commandBufferBeginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
            if ll.vkBeginCommandBuffer!(cb,&commandBufferBeginInfo) != VK_SUCCESS {
                return nil
            }
        }
        public func submit() {  // submit async, for sync version look at vkCreateFence, vkQueueSubmit(,,,fence) 
            ll.vkEndCommandBuffer!(cb)
            var submitInfo=VkSubmitInfo()
            submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO
            submitInfo.commandBufferCount = 1
            submitInfo.pCommandBuffers = UnsafePointer(UnsafeMutablePointer(&cb))
            ll.vkQueueSubmit!(engine.queue, 1, &submitInfo, nil)
        }
        deinit {
            ll.vkQueueWaitIdle!(engine.queue)
            ll.vkFreeCommandBuffers!(engine.logicalDevice, engine.commandPool, 1, &cb)
        }
        func setImageLayout(image:VkImage,aspects:VkImageAspectFlags,oldLayout:VkImageLayout,newLayout:VkImageLayout,srcFlags:VkPipelineStageFlags=VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT.rawValue,dstFlags:VkPipelineStageFlags=VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT.rawValue) {
            var imageBarrier = VkImageMemoryBarrier()
            imageBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
            imageBarrier.pNext = nil
            imageBarrier.oldLayout = oldLayout
            imageBarrier.newLayout = newLayout
            imageBarrier.image = image
            imageBarrier.subresourceRange.aspectMask = aspects
            imageBarrier.subresourceRange.baseMipLevel = 0
            imageBarrier.subresourceRange.levelCount = 1
            imageBarrier.subresourceRange.layerCount = 1
            switch oldLayout {
            case VK_IMAGE_LAYOUT_PREINITIALIZED:
                imageBarrier.srcAccessMask = VK_ACCESS_HOST_WRITE_BIT.rawValue | VK_ACCESS_TRANSFER_WRITE_BIT.rawValue
            case VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:
                imageBarrier.srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT.rawValue;
            case VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:
                imageBarrier.srcAccessMask = VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT.rawValue
            case VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:
                imageBarrier.srcAccessMask = VK_ACCESS_TRANSFER_READ_BIT.rawValue
            case VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:
                imageBarrier.srcAccessMask = VK_ACCESS_SHADER_READ_BIT.rawValue
            default:
                break
            }
            switch newLayout {
            case VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:
                imageBarrier.dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT.rawValue
            case VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:
                imageBarrier.srcAccessMask |= VK_ACCESS_TRANSFER_READ_BIT.rawValue
                imageBarrier.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT.rawValue
            case VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:
                imageBarrier.dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT.rawValue
                imageBarrier.srcAccessMask = VK_ACCESS_TRANSFER_READ_BIT.rawValue
            case VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:
                imageBarrier.dstAccessMask |= VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT.rawValue
            case VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:
                imageBarrier.srcAccessMask = VK_ACCESS_HOST_WRITE_BIT.rawValue | VK_ACCESS_TRANSFER_WRITE_BIT.rawValue
                imageBarrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT.rawValue
            default:
                break
            }
            ll.vkCmdPipelineBarrier!(cb, srcFlags, dstFlags, 0, 0, nil, 0, nil, 1, &imageBarrier);
        }
    }
    public class Texture : TinNode {
        var needStaging = false
        var image:VkImage?
        var imageLayout:VkImageLayout = VK_IMAGE_LAYOUT_UNDEFINED
        var memory:VkDeviceMemory?
        var view:VkImageView?
        var sampler:VkSampler? 
        let width:Int
        let height:Int
        public init?(engine:Tin,width:Int,height:Int,pixels:[UInt32]? = nil) {
            self.width = width
            self.height = height
            super.init(engine:engine)

            var formatProps = VkFormatProperties()
            ll.vkGetPhysicalDeviceFormatProperties!(engine.device!.physicalDevice, VK_FORMAT_R8G8B8A8_UNORM, &formatProps);
            needStaging = ((formatProps.linearTilingFeatures & VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT.rawValue) != VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT.rawValue) ? true : false

            var image_create_info = VkImageCreateInfo()
            image_create_info.sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO
            image_create_info.pNext = nil
            image_create_info.imageType = VK_IMAGE_TYPE_2D
            image_create_info.format = VK_FORMAT_B8G8R8A8_UNORM 
            image_create_info.extent.width = UInt32(width)
            image_create_info.extent.height = UInt32(height)
            image_create_info.extent.depth = 1
            image_create_info.mipLevels = 1
            image_create_info.arrayLayers = 1
            image_create_info.samples = VK_SAMPLE_COUNT_1_BIT
            image_create_info.tiling = VK_IMAGE_TILING_LINEAR
            image_create_info.initialLayout = VK_IMAGE_LAYOUT_PREINITIALIZED
            image_create_info.usage = needStaging ? VK_IMAGE_USAGE_TRANSFER_SRC_BIT.rawValue : VK_IMAGE_USAGE_SAMPLED_BIT.rawValue
            image_create_info.queueFamilyIndexCount = 0
            image_create_info.pQueueFamilyIndices = nil
            image_create_info.sharingMode = VK_SHARING_MODE_EXCLUSIVE
            image_create_info.flags = 0
            var mappableImage:VkImage?
            if ll.vkCreateImage!(engine.logicalDevice, &image_create_info, nil, &mappableImage) != VK_SUCCESS {
                return nil
            }
            var mappableMemory:VkDeviceMemory?
            var mem_reqs = VkMemoryRequirements()
            vkGetImageMemoryRequirements(engine.logicalDevice, image, &mem_reqs)
            var mem_alloc = VkMemoryAllocateInfo()
            mem_alloc.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO
            mem_alloc.pNext = nil
            mem_alloc.allocationSize = mem_reqs.size
            mem_alloc.memoryTypeIndex = 0
            if let i = engine.device?.memoryTypeIndex(typeBits:mem_reqs.memoryTypeBits,requirements: VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT.rawValue | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT.rawValue) {
                mem_alloc.memoryTypeIndex = i
            } else {
                // TODO: release Image
                return nil
            }
            if ll.vkAllocateMemory!(engine.logicalDevice, &mem_alloc, nil, &mappableMemory) != VK_SUCCESS {
                // TODO: release Image
                return nil
            }
            if ll.vkBindImageMemory!(engine.logicalDevice, mappableImage, mappableMemory, 0) != VK_SUCCESS {
                // TODO: release Image & Memory
                return nil
            }

            var subres = VkImageSubresource()
            subres.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
            subres.mipLevel = 0
            subres.arrayLayer = 0
            var layout = VkSubresourceLayout()
            ll.vkGetImageSubresourceLayout!(engine.logicalDevice, mappableImage, &subres, &layout);
            if let pixels = pixels {
                var data : UnsafeMutableRawPointer?
                if ll.vkMapMemory!(engine.logicalDevice, mappableMemory, 0, mem_reqs.size, 0, UnsafeMutablePointer(&data)) == VK_SUCCESS {
                    memcpy(data!,pixels,4*width*height)
                    ll.vkUnmapMemory!(engine.logicalDevice, mappableMemory)
                }
            }

            if let cb = CommandBuffer(engine:engine) {
                if !needStaging {
                    self.image = mappableImage
                    self.memory = mappableImage
                    self.imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
                    cb.setImageLayout(image:self.image!,aspects:VK_IMAGE_ASPECT_COLOR_BIT.rawValue,oldLayout:VK_IMAGE_LAYOUT_PREINITIALIZED,newLayout:self.imageLayout,srcFlags:VK_PIPELINE_STAGE_HOST_BIT.rawValue,dstFlags:VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT.rawValue)
                } else {
                    image_create_info.tiling = VK_IMAGE_TILING_OPTIMAL
                    image_create_info.usage = VK_IMAGE_USAGE_TRANSFER_DST_BIT.rawValue | VK_IMAGE_USAGE_SAMPLED_BIT.rawValue
                    image_create_info.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED
                    if ll.vkCreateImage!(engine.logicalDevice, &image_create_info, nil, &self.image) != VK_SUCCESS {
                        // TODO: clear...
                        return nil
                    }
                    ll.vkGetImageMemoryRequirements!(engine.logicalDevice, self.image, &mem_reqs)
                    mem_alloc.allocationSize = mem_reqs.size
                    if let i = engine.device?.memoryTypeIndex(typeBits:mem_reqs.memoryTypeBits,requirements: VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT.rawValue | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT.rawValue) {
                        mem_alloc.memoryTypeIndex = i
                    } else {
                        // TODO: clear...
                        return nil
                    }
                    if ll.vkAllocateMemory!(engine.logicalDevice, &mem_alloc, nil, &self.memory) != VK_SUCCESS {
                        // TODO: clear...
                        return nil
                    }
                    if ll.vkBindImageMemory!(engine.logicalDevice, self.image, self.memory, 0) != VK_SUCCESS {
                        // TODO: clear...
                        return nil
                    }
                    cb.setImageLayout(image:mappableImage!,aspects:VK_IMAGE_ASPECT_COLOR_BIT.rawValue,oldLayout:VK_IMAGE_LAYOUT_PREINITIALIZED,newLayout:VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,srcFlags:VK_PIPELINE_STAGE_HOST_BIT.rawValue,dstFlags:VK_PIPELINE_STAGE_TRANSFER_BIT.rawValue)
                    cb.setImageLayout(image:self.image!,aspects:VK_IMAGE_ASPECT_COLOR_BIT.rawValue,oldLayout:VK_IMAGE_LAYOUT_UNDEFINED,newLayout:VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,srcFlags:VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT.rawValue,dstFlags:VK_PIPELINE_STAGE_TRANSFER_BIT.rawValue)
                    var copy_region = VkImageCopy()
                    copy_region.srcSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
                    copy_region.srcSubresource.mipLevel = 0
                    copy_region.srcSubresource.baseArrayLayer = 0
                    copy_region.srcSubresource.layerCount = 1
                    copy_region.srcOffset.x = 0
                    copy_region.srcOffset.y = 0
                    copy_region.srcOffset.z = 0
                    copy_region.dstSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
                    copy_region.dstSubresource.mipLevel = 0
                    copy_region.dstSubresource.baseArrayLayer = 0
                    copy_region.dstSubresource.layerCount = 1
                    copy_region.dstOffset.x = 0
                    copy_region.dstOffset.y = 0
                    copy_region.dstOffset.z = 0
                    copy_region.extent.width = UInt32(width)
                    copy_region.extent.height = UInt32(height)
                    copy_region.extent.depth = 1
                    ll.vkCmdCopyImage!(cb.cb!, mappableImage!, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, self.image!, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &copy_region)
                    self.imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
                    cb.setImageLayout(image:self.image!,aspects:VK_IMAGE_ASPECT_COLOR_BIT.rawValue,oldLayout:VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,newLayout:self.imageLayout,srcFlags:VK_PIPELINE_STAGE_TRANSFER_BIT.rawValue,dstFlags:VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT.rawValue)
                }
                cb.submit()
            }
            var samplerCreateInfo = VkSamplerCreateInfo()
            samplerCreateInfo.sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO
            samplerCreateInfo.magFilter = VK_FILTER_LINEAR
            samplerCreateInfo.minFilter = VK_FILTER_CUBIC_IMG
            samplerCreateInfo.mipmapMode = VK_SAMPLER_MIPMAP_MODE_LINEAR
            samplerCreateInfo.addressModeU = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE
            samplerCreateInfo.addressModeV = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE
            samplerCreateInfo.addressModeW = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE
            samplerCreateInfo.mipLodBias = 0.0
            samplerCreateInfo.anisotropyEnable = VkBool32(VK_FALSE)
            samplerCreateInfo.maxAnisotropy = 1
            samplerCreateInfo.compareEnable = VkBool32(VK_FALSE)
            samplerCreateInfo.compareOp = VK_COMPARE_OP_NEVER
            samplerCreateInfo.minLod = 0.0
            samplerCreateInfo.maxLod = 0.0
            samplerCreateInfo.borderColor = VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE
            if ll.vkCreateSampler!(engine.logicalDevice, &samplerCreateInfo, nil, &self.sampler) != VK_SUCCESS {
                // TODO: clear
                return nil
            }
            var view_info = VkImageViewCreateInfo()
            view_info.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO
            view_info.pNext = nil
            view_info.image = self.image
            view_info.viewType = VK_IMAGE_VIEW_TYPE_2D
            view_info.format = VK_FORMAT_R8G8B8A8_UNORM
            view_info.components.r = VK_COMPONENT_SWIZZLE_R
            view_info.components.g = VK_COMPONENT_SWIZZLE_G
            view_info.components.b = VK_COMPONENT_SWIZZLE_B
            view_info.components.a = VK_COMPONENT_SWIZZLE_A
            view_info.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
            view_info.subresourceRange.baseMipLevel = 0
            view_info.subresourceRange.levelCount = 1
            view_info.subresourceRange.baseArrayLayer = 0
            view_info.subresourceRange.layerCount = 1
            if ll.vkCreateImageView!(engine.logicalDevice, &view_info, nil, &self.view) != VK_SUCCESS {
                // TODO: clear...
                return nil
            }
            if self.needStaging {
                ll.vkFreeMemory!(engine.logicalDevice, mappableMemory, nil)
                ll.vkDestroyImage!(engine.logicalDevice, mappableImage, nil)                
            }
        }
        deinit {
            if sampler != nil {
                ll.vkDestroySampler!(engine.logicalDevice,sampler,nil)
                sampler = nil
            }
            if view != nil {
                ll.vkDestroyImageView!(engine.logicalDevice,view,nil)
                view = nil
            }
            if image != nil {
                ll.vkDestroyImage!(engine.logicalDevice,image,nil)
                image = nil
            }
            if memory != nil {
                ll.vkFreeMemory!(engine.logicalDevice,memory,nil)
                memory = nil
            }
        }
    }
    public class RenderCommandEncoder {
        public init() {
            // TODO: ???
        }
    }
    public class RenderPass : TinNode {
        var renderPass:VkRenderPass?
        var cb:CommandBuffer?
        var framebuffer:VkFramebuffer?
        init?(engine:Tin, to image:Image) {
            super.init(engine:engine)
            var colorAttachment = VkAttachmentDescription()
            colorAttachment.format = VK_FORMAT_B8G8R8A8_UNORM
            colorAttachment.samples = VK_SAMPLE_COUNT_1_BIT
            colorAttachment.loadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE
            colorAttachment.storeOp = VK_ATTACHMENT_STORE_OP_DONT_CARE
            colorAttachment.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE
            colorAttachment.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE
            colorAttachment.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED
            colorAttachment.finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
            var colorAttachmentRef = VkAttachmentReference()
            colorAttachmentRef.attachment = 0;
            colorAttachmentRef.layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
            var subpass = VkSubpassDescription()
            subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS
            subpass.colorAttachmentCount = 1
            subpass.pColorAttachments = UnsafePointer(UnsafeMutablePointer(&colorAttachmentRef))
            var renderPassInfo = VkRenderPassCreateInfo()
            renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO
            renderPassInfo.attachmentCount = 1;
            renderPassInfo.pAttachments = UnsafePointer(UnsafeMutablePointer(&colorAttachment))
            renderPassInfo.subpassCount = 1
            renderPassInfo.pSubpasses = UnsafePointer(UnsafeMutablePointer(&subpass))
            if ll.vkCreateRenderPass!(engine.logicalDevice, &renderPassInfo, nil, &renderPass) != VK_SUCCESS {
                return nil
            }
            framebuffer = image.createFramebuffer(renderPass:self)
            begin(width:image.width,height:image.height,framebuffer:framebuffer!)
        }
        deinit {
            if framebuffer != nil {
                ll.vkDestroyFramebuffer!(engine.logicalDevice, framebuffer, nil)
            }
        }
        public init?(engine:Tin, to texture:Texture) {
            super.init(engine:engine)
            // TODO:
            NSLog("Not Implemented")
        }
        func begin(width:Int,height:Int,framebuffer:VkFramebuffer) {
            cb = CommandBuffer(engine:engine)
            var rp_begin = VkRenderPassBeginInfo()
            rp_begin.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO
            rp_begin.pNext = nil
            rp_begin.renderPass = renderPass
            rp_begin.framebuffer = framebuffer
            rp_begin.renderArea.offset.x = 0
            rp_begin.renderArea.offset.y = 0
            rp_begin.renderArea.extent.width = UInt32(width)
            rp_begin.renderArea.extent.height = UInt32(height)
            var clear = [VkClearValue](repeating:VkClearValue(), count:2)
            clear[0].color.uint32.0 = 0
            clear[0].color.uint32.1 = 0
            clear[0].color.uint32.2 = 0
            clear[0].color.uint32.3 = 0
            clear[1].depthStencil.depth = 1.0
            rp_begin.clearValueCount = UInt32(clear.count)
            rp_begin.pClearValues = UnsafePointer(UnsafeMutablePointer(&clear))
            ll.vkCmdBeginRenderPass!(cb!.cb, &rp_begin, VK_SUBPASS_CONTENTS_INLINE);
        }
        public func draw() {
            // https://www.khronos.org/registry/vulkan/specs/1.0/html/vkspec.html#drawing
            // TODO: vkCmdBindPipeline (Aether.Program)
            // TODO: vkCmdDraw
        }
    }
    public class Pipeline : TinNode {
        // https://vulkan-tutorial.com/Drawing_a_triangle/Graphics_pipeline_basics/Introduction
        // https://www.khronos.org/registry/vulkan/specs/1.0/html/vkspec.html#pipelines-graphics
        public enum VertexFormat {
            case float
            case float2
            case float3
            case float4
            var bytes : Int {
                switch self {
                    case .float: 
                    return 4
                    case .float2: 
                    return 8
                    case .float3: 
                    return 12
                    case .float4: 
                    return 16
                }
            }
            var format : VkFormat {
                switch self {
                    case .float: 
                    return VK_FORMAT_R32_SFLOAT
                    case .float2: 
                    return VK_FORMAT_R32G32_SFLOAT
                    case .float3: 
                    return VK_FORMAT_R32G32B32_SFLOAT
                    case .float4: 
                    return VK_FORMAT_R32G32B32A32_SFLOAT
                }
            }
        }
        var vertex : VkShaderModule?
        var fragment : VkShaderModule?
        var pipeline:VkPipeline?
        public init?(engine:Tin,vertex:[UInt8],fragment:[UInt8],format:[VertexFormat]) {
            super.init(engine:engine)
            self.vertex = createShaderModule(code:vertex)
            self.fragment = createShaderModule(code:fragment)
            if !self.createPipeline(format:format) {
                // TODO: destroy shaders
                return nil
            }
        }
        deinit {

        }
        func createShaderModule(code:[UInt8]) -> VkShaderModule? {
            var createInfo = VkShaderModuleCreateInfo()
            createInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
            createInfo.codeSize = code.count
            if (code.count & 3) != 0 || code.count == 0 {
                NSLog("urdidium: error spir-v code invalid")
            }
            createInfo.pCode = UnsafeRawPointer(code).assumingMemoryBound(to:UInt32.self)
            var shader : VkShaderModule?
            ll.vkCreateShaderModule!(engine.logicalDevice,&createInfo,nil,&shader)
            return shader
        }
        func createPipeline(format:[VertexFormat]) -> Bool {
            var pipelineInfo = VkGraphicsPipelineCreateInfo()
            pipelineInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO

            var stages = [VkPipelineShaderStageCreateInfo]()
            var infoVertex = VkPipelineShaderStageCreateInfo()
            infoVertex.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
            infoVertex.stage = VK_SHADER_STAGE_VERTEX_BIT
            infoVertex.pName = UnsafeRawPointer("vertex").assumingMemoryBound(to:Int8.self)
            infoVertex.module = self.vertex
            stages.append(infoVertex)
            var infoFragment = VkPipelineShaderStageCreateInfo()
            infoFragment.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
            infoFragment.stage = VK_SHADER_STAGE_FRAGMENT_BIT
            infoFragment.pName = UnsafeRawPointer("fragment").assumingMemoryBound(to:Int8.self)
            infoFragment.module = self.fragment
            stages.append(infoFragment)
            pipelineInfo.stageCount = UInt32(stages.count)
            pipelineInfo.pStages = UnsafePointer(UnsafeMutablePointer(mutating:stages))

            var vertexInput = VkPipelineVertexInputStateCreateInfo()
            vertexInput.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
            var attributes = [VkVertexInputAttributeDescription]()
            var size = 0
            var n = 0
            for vf in format {
                var d = VkVertexInputAttributeDescription()
                d.location = UInt32(n)
                d.offset = UInt32(size)
                attributes.append(d)
                n += 1
                size += vf.bytes
                attributes.append(d)
            }
            vertexInput.vertexAttributeDescriptionCount = UInt32(attributes.count)
            vertexInput.pVertexAttributeDescriptions = UnsafePointer(UnsafeMutablePointer(mutating:attributes))
            var binding = VkVertexInputBindingDescription()
            binding.binding = 0
            binding.stride = UInt32(size)
            binding.inputRate = VK_VERTEX_INPUT_RATE_VERTEX
            vertexInput.vertexBindingDescriptionCount = 1
            vertexInput.pVertexBindingDescriptions = UnsafePointer(UnsafeMutablePointer(mutating:&binding))
            pipelineInfo.pVertexInputState = UnsafePointer(UnsafeMutablePointer(mutating:&vertexInput))

            var assembly = VkPipelineInputAssemblyStateCreateInfo()
            assembly.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
            assembly.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST // VkPrimitiveTopology
            assembly.primitiveRestartEnable = VkBool32(VK_FALSE)
            pipelineInfo.pInputAssemblyState = UnsafePointer(UnsafeMutablePointer(mutating:&assembly))

            var viewports = VkPipelineViewportStateCreateInfo()
            viewports.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO
            var vps = [VkViewport]()
            var vp = VkViewport()  
            vp.x = -1
            vp.y = 1
            vp.width = 2
            vp.height = 2
            vp.minDepth = 0
            vp.maxDepth = 1
            vps.append(vp)
            viewports.viewportCount = UInt32(vps.count)
            viewports.pViewports = UnsafePointer(UnsafeMutablePointer(mutating:vps))
            pipelineInfo.pViewportState = UnsafePointer(UnsafeMutablePointer(mutating:&viewports))

            var rasterization = VkPipelineRasterizationStateCreateInfo()
            rasterization.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
            rasterization.depthClampEnable = VkBool32(VK_TRUE)
            rasterization.rasterizerDiscardEnable = VkBool32(VK_TRUE)
            rasterization.polygonMode = VK_POLYGON_MODE_FILL         // VkPolygonMode
            rasterization.cullMode = VK_CULL_MODE_BACK_BIT.rawValue  // VkCullModeFlagBits
            rasterization.frontFace = VK_FRONT_FACE_CLOCKWISE        // VkFrontFace
            rasterization.depthBiasEnable = VkBool32(VK_FALSE)
            rasterization.lineWidth = 1
            pipelineInfo.pRasterizationState = UnsafePointer(UnsafeMutablePointer(mutating:&rasterization))

            // https://www.khronos.org/registry/vulkan/specs/1.0/html/vkspec.html#primsrast-sampleshading
            var multisample = VkPipelineMultisampleStateCreateInfo()
            multisample.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
            multisample.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT   // VkSampleCountFlagBits
            multisample.sampleShadingEnable = VkBool32(VK_FALSE)
            multisample.minSampleShading = 1
            multisample.pSampleMask = nil
            multisample.alphaToCoverageEnable = VkBool32(VK_FALSE)
            multisample.alphaToOneEnable = VkBool32(VK_FALSE)
            pipelineInfo.pMultisampleState = UnsafePointer(UnsafeMutablePointer(mutating:&multisample))

            var depthstencil = VkPipelineDepthStencilStateCreateInfo()
            depthstencil.sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO
            depthstencil.depthTestEnable = VkBool32(VK_FALSE)   // TODO: enable depth test
            depthstencil.depthWriteEnable = VkBool32(VK_FALSE)
            depthstencil.depthCompareOp = VK_COMPARE_OP_LESS
            depthstencil.depthBoundsTestEnable = VkBool32(VK_FALSE)
            depthstencil.stencilTestEnable = VkBool32(VK_FALSE)
            // depthstencil.front =
            // depthstencil.back =
            depthstencil.minDepthBounds = 0
            depthstencil.maxDepthBounds = 1
            pipelineInfo.pDepthStencilState = UnsafePointer(UnsafeMutablePointer(mutating:&depthstencil))
            
            var blend = VkPipelineColorBlendStateCreateInfo()
                // https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkPipelineColorBlendStateCreateInfo.html
            blend.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO
            blend.logicOpEnable = VkBool32(VK_FALSE)
            blend.logicOp = VK_LOGIC_OP_SET                  // VkLogicOp, special blend (or,and,xor..)
            blend.attachmentCount = 1
            var att = VkPipelineColorBlendAttachmentState()
            att.blendEnable = VkBool32(VK_FALSE)            // TODO: ennable blend
            att.srcColorBlendFactor = VK_BLEND_FACTOR_ONE   // VkBlendFactor
            att.dstColorBlendFactor = VK_BLEND_FACTOR_ONE
            att.colorBlendOp = VK_BLEND_OP_ADD
            att.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE
            att.dstAlphaBlendFactor  = VK_BLEND_FACTOR_ONE
            att.alphaBlendOp = VK_BLEND_OP_MAX
            att.colorWriteMask = VK_COLOR_COMPONENT_R_BIT.rawValue | VK_COLOR_COMPONENT_G_BIT.rawValue | VK_COLOR_COMPONENT_B_BIT.rawValue | VK_COLOR_COMPONENT_A_BIT.rawValue
            blend.pAttachments = UnsafePointer(UnsafeMutablePointer(mutating:&att))
            blend.blendConstants.0 = 1.0 // R
            blend.blendConstants.1 = 1.0 // G
            blend.blendConstants.2 = 1.0 // B
            blend.blendConstants.3 = 1.0 // A
            pipelineInfo.pColorBlendState = UnsafePointer(UnsafeMutablePointer(mutating:&blend))
            
            var dynamic = VkPipelineDynamicStateCreateInfo()
            depthstencil.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO

            var dyn = [VkDynamicState]()
            // dyn.append(VK_DYNAMIC_STATE_SCISSOR)
            dynamic.dynamicStateCount = UInt32(dyn.count)
            dynamic.pDynamicStates = UnsafePointer(UnsafeMutablePointer(mutating:dyn))
            pipelineInfo.pDynamicState = UnsafePointer(UnsafeMutablePointer(mutating:&dynamic))
            return ll.vkCreateGraphicsPipelines!(engine.logicalDevice,nil,1, &pipelineInfo,nil,&pipeline) == VK_SUCCESS
        }
    }
    public class Buffer : TinNode {
        // https://vulkan-tutorial.com/Vertex_buffers/Vertex_buffer_creation
        public struct Usage : OptionSet {
            public let rawValue:Int
            public static let transferSrc = Usage(rawValue: Int(VK_BUFFER_USAGE_TRANSFER_SRC_BIT.rawValue))
            public static let transferDst = Usage(rawValue: Int(VK_BUFFER_USAGE_TRANSFER_DST_BIT.rawValue))
            public static let uniformTexel = Usage(rawValue: Int(VK_BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT.rawValue))
            public static let storageTexel = Usage(rawValue: Int(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT.rawValue))
            public static let UniformBuffer = Usage(rawValue: Int(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT.rawValue))
            public static let stotageBuffer = Usage(rawValue: Int(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT.rawValue))
            public static let indexBuffer = Usage(rawValue: Int(VK_BUFFER_USAGE_INDEX_BUFFER_BIT.rawValue))
            public static let vertexBuffer = Usage(rawValue: Int(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT.rawValue))
            public static let indirectBuffer = Usage(rawValue: Int(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT.rawValue))
            public init(rawValue:Int) {
                self.rawValue = rawValue
            }
        }
        var buffer:VkBuffer?
        var memory:VkDeviceMemory?
        public private(set) var size:Int
        public init?(engine:Tin,size:Int,usage:Usage=[.UniformBuffer,.indexBuffer,.vertexBuffer]) {
            self.size = size
            super.init(engine:engine)
            var ci = VkBufferCreateInfo()
            ci.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO
            ci.size = UInt64(size)
            ci.usage = UInt32(usage.rawValue)
            ci.sharingMode = VK_SHARING_MODE_EXCLUSIVE
            if ll.vkCreateBuffer!(engine.logicalDevice, &ci, nil, &buffer) != VK_SUCCESS {
                return nil
            }
            var memRequirements = VkMemoryRequirements()
            ll.vkGetBufferMemoryRequirements!(engine.logicalDevice, buffer, &memRequirements)
            var allocInfo = VkMemoryAllocateInfo()
            allocInfo.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO
            allocInfo.allocationSize = memRequirements.size
            allocInfo.memoryTypeIndex = 0
            if ll.vkAllocateMemory!(engine.logicalDevice, &allocInfo, nil, &memory) != VK_SUCCESS {
                return nil
            }
            ll.vkBindBufferMemory!(engine.logicalDevice, buffer, memory, 0);            
        }
        deinit {
            if memory != nil {
                ll.vkFreeMemory!(engine.logicalDevice,memory,nil)
                memory = nil
            }
            if buffer != nil {
                ll.vkDestroyBuffer!(engine.logicalDevice, buffer, nil)
                buffer = nil
            }
        }
        public func withMemoryMap(fn:(UnsafeMutableRawPointer)->()) {
            var data : UnsafeMutableRawPointer?
            if ll.vkMapMemory!(engine.logicalDevice, memory, 0, UInt64(size), 0, UnsafeMutablePointer(&data)) == VK_SUCCESS {
                fn(data!)
                ll.vkUnmapMemory!(engine.logicalDevice, memory)
            }
        }
    }
    class Image {
        let ll:LunarLayer
        let engine:Tin
        var image:VkImage
        var view:VkImageView?
        var width:Int 
        var height:Int
        init(engine:Tin,image:VkImage,width:Int,height:Int) {
            self.ll = engine.ll
            self.engine = engine
            self.image = image
            self.width = width
            self.height = height
            if let cb = CommandBuffer(engine:engine) {
                cb.setImageLayout(image:image,aspects:VK_IMAGE_ASPECT_COLOR_BIT.rawValue,oldLayout:VK_IMAGE_LAYOUT_UNDEFINED,newLayout:VK_IMAGE_LAYOUT_PRESENT_SRC_KHR)
                cb.submit()
            }
            var imageCreateInfo = VkImageViewCreateInfo()
            imageCreateInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO
            imageCreateInfo.pNext = nil
            imageCreateInfo.format = VK_FORMAT_B8G8R8A8_UNORM
            var comps = VkComponentMapping()
            comps.r = VK_COMPONENT_SWIZZLE_R
            comps.g = VK_COMPONENT_SWIZZLE_G
            comps.b = VK_COMPONENT_SWIZZLE_B
            comps.a = VK_COMPONENT_SWIZZLE_A
            imageCreateInfo.components = comps
            imageCreateInfo.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
            imageCreateInfo.subresourceRange.baseMipLevel = 0
            imageCreateInfo.subresourceRange.levelCount = 1
            imageCreateInfo.subresourceRange.baseArrayLayer = 0
            imageCreateInfo.subresourceRange.layerCount = 1
            imageCreateInfo.viewType = VK_IMAGE_VIEW_TYPE_2D
            imageCreateInfo.flags = 0
            imageCreateInfo.image = image
            if ll.vkCreateImageView!(engine.logicalDevice, &imageCreateInfo, nil, &view) != VK_SUCCESS {
                NSLog("urdidium: can't create image view")
            }
        }
        deinit {
            ll.vkDestroyImageView!(engine.logicalDevice, view, nil)
        }
        func createFramebuffer(renderPass:RenderPass) -> VkFramebuffer? {
            var fbCreateInfo = VkFramebufferCreateInfo()
            fbCreateInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO
            fbCreateInfo.attachmentCount = 1
            fbCreateInfo.pAttachments = UnsafePointer(UnsafeMutablePointer(&view))
            fbCreateInfo.width = UInt32(width)
            fbCreateInfo.height = UInt32(height)
            fbCreateInfo.layers = 1
            var framebuffer : VkFramebuffer?
            if ll.vkCreateFramebuffer!(engine.logicalDevice, &fbCreateInfo, nil, &framebuffer) == VK_SUCCESS {
                return framebuffer
            }
            return nil
        }
    }
    class Swapchain : TinNode {
        public private(set) var colorFormat : VkFormat = VK_FORMAT_B8G8R8A8_UNORM
        var swapchain:VkSwapchainKHR?
        var images=[Image]()
        var imageIndex:UInt32=0
        init?(engine:Tin,width:Int,height:Int) {
            super.init(engine:engine)
            if !self.createSwapchain(width: width, height: width) {
                return nil
            }
        }
        func createSwapchain(width:Int,height:Int) -> Bool {
            var iskhr = VkBool32(VK_FALSE)
            ll.vkGetPhysicalDeviceSurfaceSupportKHR!(engine.device!.physicalDevice,engine.queueIndex,engine.surface,&iskhr)
            if iskhr != VK_FALSE {
                var fcount : UInt32 = 0
                ll.vkGetPhysicalDeviceSurfaceFormatsKHR!(engine.device!.physicalDevice,engine.surface,&fcount,nil)
                if fcount>0 {
                    var formats = [VkSurfaceFormatKHR](repeating:VkSurfaceFormatKHR(),count:Int(fcount))
                    if ll.vkGetPhysicalDeviceSurfaceFormatsKHR!(engine.device!.physicalDevice,engine.surface,&fcount,&formats) == VK_SUCCESS {
                        for f in formats {
                            if f.format == VK_FORMAT_B8G8R8A8_UNORM {
                                colorFormat = VK_FORMAT_B8G8R8A8_UNORM
                                NSLog("urdidium: color BGRA")
                                break
                            } else if f.format == VK_FORMAT_R8G8B8A8_UNORM {
                                colorFormat = VK_FORMAT_R8G8B8A8_UNORM
                                NSLog("urdidium: color GRBA")
                            }
                        }
                    }
                }
                var caps = VkSurfaceCapabilitiesKHR() 
                if ll.vkGetPhysicalDeviceSurfaceCapabilitiesKHR!(engine.device!.physicalDevice,engine.surface,&caps) == VK_SUCCESS {
                    var size = VkExtent2D()
                    if caps.currentExtent.width == 0xFFFFFFFF || caps.currentExtent.height == 0xFFFFFFFF {
                        size.width = UInt32(width)
                        size.height = UInt32(height)
                    } else {
                        size = caps.currentExtent
                    }
                    var presentModeCount : UInt32 = 0
                    var presentModes = [VkPresentModeKHR]()
                    if ll.vkGetPhysicalDeviceSurfacePresentModesKHR!(engine.device!.physicalDevice,engine.surface,&presentModeCount,nil) == VK_SUCCESS && presentModeCount>0 {
                        presentModes = [VkPresentModeKHR](repeating:VK_PRESENT_MODE_MAX_ENUM_KHR,count:Int(presentModeCount))
                        vkGetPhysicalDeviceSurfacePresentModesKHR(engine.device!.physicalDevice,engine.surface,&presentModeCount,&presentModes)
                    }
                    var pmode = VK_PRESENT_MODE_IMMEDIATE_KHR
                    for pm in presentModes {
                        if pm == VK_PRESENT_MODE_FIFO_KHR {
                            pmode = pm
                            break
                        }
                    }
                    var swapchainCreateInfo = VkSwapchainCreateInfoKHR()
                    swapchainCreateInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
                    swapchainCreateInfo.surface = engine.surface
                    swapchainCreateInfo.minImageCount = 2
                    swapchainCreateInfo.imageFormat = colorFormat
                    swapchainCreateInfo.imageColorSpace = VK_COLOR_SPACE_SRGB_NONLINEAR_KHR
                    swapchainCreateInfo.imageExtent = size
                    swapchainCreateInfo.imageArrayLayers = 1
                    swapchainCreateInfo.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue
                    swapchainCreateInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE
                    swapchainCreateInfo.queueFamilyIndexCount = 1
                    var indice : UInt32 = 0
                    swapchainCreateInfo.pQueueFamilyIndices = UnsafePointer(UnsafeMutablePointer(&indice))
                    swapchainCreateInfo.preTransform = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR
                    swapchainCreateInfo.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
                    swapchainCreateInfo.presentMode = pmode
                    swapchainCreateInfo.oldSwapchain = swapchain
                    if ll.vkCreateSwapchainKHR!(engine.logicalDevice, &swapchainCreateInfo, nil, &swapchain) == VK_SUCCESS {
                        let mode = pmode == VK_PRESENT_MODE_FIFO_KHR ? "mode: fifo" : ""
                        NSLog("urdidium: swapchain OK, \(mode)")
                        var imageCount:UInt32 = 0
                        if ll.vkGetSwapchainImagesKHR!(engine.logicalDevice, swapchain, &imageCount, nil) == VK_SUCCESS {
                            var images = [VkImage?](repeating:nil,count:Int(imageCount))
                            if ll.vkGetSwapchainImagesKHR!(engine.logicalDevice, swapchain, &imageCount, &images) == VK_SUCCESS {
                                for image in images {
                                    self.images.append(Image(engine:engine,image:image!,width:Int(size.width),height:Int(size.height)))
                                }
                                if images.count == self.images.count {
                                    NSLog("urdidium: images OK, count: \(imageCount)")
                                    return true
                                }
                            }
                        }
                    }
                }
            } else {
                NSLog("urdidium: not implemented")
                // TODO: ???
            }
            return false
        }
        func destroySwapchain() {
            ll.vkDeviceWaitIdle!(engine.logicalDevice)
            images.removeAll()
            ll.vkDestroySwapchainKHR!(engine.logicalDevice,swapchain,nil)
        }
        func resizeSwapchain(width:Int,height:Int) {
            destroySwapchain()
            createSwapchain(width:width,height:height)
        }
        func aquire() -> Bool {
            vkQueueWaitIdle(engine.queue)
            imageIndex = (imageIndex + 1) & 1
            if ll.vkAcquireNextImageKHR!(engine.logicalDevice,swapchain,100000000,nil,nil,&imageIndex) == VK_SUCCESS {
                return true
            }
            return false
        }
        func present() -> Bool {
            if let queue = engine.queue {
                var presentInfo = VkPresentInfoKHR()
                presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
                presentInfo.pNext = nil
                presentInfo.swapchainCount = 1
                presentInfo.pSwapchains = UnsafePointer(UnsafeMutablePointer(&swapchain))
                presentInfo.pImageIndices = UnsafePointer(UnsafeMutablePointer(&imageIndex))
                if ll.vkQueuePresentKHR!(queue, &presentInfo) == VK_SUCCESS {
                    return true
                }
            }
            return false
        }
    }
    class Fence : TinNode {           // GPU -> CPU   // manual reset
        var fence:VkFence?
        override init?(engine:Tin) {
            super.init(engine:engine)
            var info = VkFenceCreateInfo()
            info.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO
            if vkCreateFence(engine.logicalDevice,&info,nil,&fence) != VK_SUCCESS {
                return nil
            }
        }
        deinit {
            vkDestroyFence(engine.logicalDevice,fence,nil)
        }
        func reset() {
            vkResetFences(engine.logicalDevice,1,&fence)
        }
        var signaled : Bool {
            return vkGetFenceStatus(engine.logicalDevice,fence) == VK_SUCCESS
        }
    }
    class Semaphore : TinNode {       // GPU -> GPU   // auto reset
        var semaphore:VkSemaphore?
        override init?(engine:Tin) {
            super.init(engine:engine)
            var info = VkSemaphoreCreateInfo()
            info.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO
            if vkCreateSemaphore(engine.logicalDevice,&info,nil,&semaphore) != VK_SUCCESS {
                return nil
            }
        }
        deinit {
            vkDestroySemaphore(engine.logicalDevice,semaphore,nil)
        }
    }
    public struct Color {
        var r:UInt32
        var g:UInt32
        var b:UInt32
        var a:UInt32
    }

    var window:Window
    var instance:VkInstance?=nil
    var ll:LunarLayer
    var surface:VkSurfaceKHR?=nil
    var devices=[Device]()
    var device:Device?
    var logicalDevice:VkDevice? 
    var commandPool:VkCommandPool?
    var queue:VkQueue?
    var queueIndex:UInt32 = 0
    var swapchain:Swapchain?

    init(window:Window) {
        self.window = window
        self.ll = LunarLayer()
        if createInstance(app:window.title) {
            ll.instantiate(instance!)
            enumerateDevices()
            createDevice(0)
            createQueue()
            createCommandPool()
            createSurface()
            swapchain = Swapchain(engine:self,width:window.width,height:window.height)
        }
    }
    deinit {
        NSLog("urdidium: destroy")
        if let device = logicalDevice {
            ll.vkDeviceWaitIdle!(device)
        }
        if instance != nil {
            swapchain = nil
            NSLog("urdidium: swapchain destroyed")
            if logicalDevice != nil {
                ll.vkDestroyDevice!(logicalDevice, nil)
                logicalDevice = nil
            }
            NSLog("urdidium: device destroyed")
            if surface != nil {
                ll.vkDestroySurfaceKHR!(instance,surface,nil)
                surface = nil
            }
            NSLog("urdidium: surface destroyed")
            ll.vkDestroyInstance!(instance,nil)
            instance = nil
            NSLog("urdidium: instance destroyed")
        }
    }

    func makeVersion(_ major:Int,_ minor:Int,_ patch:Int) -> UInt32 {
        return UInt32( ((major) << 22) | ((minor) << 12) | (patch) )
    }
    func createInstance(app:String) -> Bool {
        var appInfo = VkApplicationInfo()
        appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO
        appInfo.apiVersion = makeVersion(1, 0, 43)
        appInfo.pNext = nil
        appInfo.pApplicationName = UnsafePointer(app)
        appInfo.pEngineName = UnsafePointer("uridium")
        var icInfo = VkInstanceCreateInfo()
        icInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
        icInfo.pNext = nil
        icInfo.flags = 0
        var result : VkResult = VK_INCOMPLETE
        var names = [UnsafePointer<Int8>]()
        if ll.lunar {
            let enabled=["VK_LAYER_LUNARG_api_dump","VK_LAYER_LUNARG_standard_validation"]
            for l in ll.layers() {
                if enabled.contains(l.name) {
                    names.append(strdup(l.name))
                    NSLog("urdidium: \(l.name) enabled")
                }
            }
            icInfo.enabledLayerCount = UInt32(names.count)
            icInfo.ppEnabledLayerNames = UnsafeRawPointer(names).assumingMemoryBound(to:UnsafePointer<Int8>?.self)
        }
        var ext = [ VK_KHR_SURFACE_EXTENSION_NAME,VK_KHR_XCB_SURFACE_EXTENSION_NAME]
        if ll.lunar {
            ext.append(VK_EXT_DEBUG_REPORT_EXTENSION_NAME)
            NSLog("urdidium: enable debug report extension")
        } else {
            NSLog("urdidium: enable debug report extension")
        }
        var pext = ext.map { UnsafePointer<Int8>(strdup($0)) }
        icInfo.enabledExtensionCount = UInt32(ext.count)
        icInfo.ppEnabledExtensionNames = UnsafeRawPointer(pext).assumingMemoryBound(to:UnsafePointer<Int8>?.self)
        icInfo.pApplicationInfo = UnsafePointer(UnsafeMutablePointer(&appInfo))
        result = ll.vkCreateInstance!(&icInfo,nil,&instance)
        switch result {
            case VK_ERROR_EXTENSION_NOT_PRESENT:
            NSLog("urdidium: instance: extension not available")
            case VK_ERROR_INCOMPATIBLE_DRIVER:
            NSLog("urdidium: intance: incompatible driver")
            case VK_SUCCESS:
            NSLog("urdidium: Instance OK")
            default:
            NSLog("urdidium: Instance error: \(result)")
        }
        for e in pext {
            free(UnsafeMutableRawPointer(mutating:e))
        }
        return result == VK_SUCCESS
    }
    func createSurface() {
        var scinfo = VkXcbSurfaceCreateInfoKHR()
        scinfo.sType = VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR
        scinfo.pNext = nil
        scinfo.flags = 0
        scinfo.connection = window.connection
        scinfo.window = window.windowId
        let result = ll.vkCreateXcbSurfaceKHR!(instance, &scinfo, nil, &surface)
        switch result {
            case VK_SUCCESS:
            NSLog("urdidium: Surface OK")
            default:
            NSLog("urdidium: Surface error: \(result)")
        }
    }
    func enumerateDevices() {
        var deviceCount:UInt32 = 0
        var result = vkEnumeratePhysicalDevices(instance, &deviceCount, nil)
        if result == VK_SUCCESS && deviceCount>0 {
            var dev = [VkPhysicalDevice?](repeating:nil, count:Int(deviceCount))
            result = ll.vkEnumeratePhysicalDevices!(instance, &deviceCount, &dev)
            if result == VK_SUCCESS {
                NSLog("urdidium: found \(deviceCount) device")
                for i in 0..<Int(deviceCount) {
                    var prop = VkPhysicalDeviceProperties()
                    vkGetPhysicalDeviceProperties(dev[i],&prop)
                    let p = Device(ll:ll,device: dev[i]!, properties:prop)
                    devices.append(p)
                    NSLog("urdidium: device \(p.deviceName)")
                }
            }
        } else {
            NSLog("urdidium: error \(result), no device")
        }
    }
    func createDevice(_ idev:Int) {
        device = devices[idev]
        var queueInfo = VkDeviceQueueCreateInfo()
        queueInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
        queueInfo.pNext = nil
        queueInfo.flags = 0
        queueInfo.queueFamilyIndex = 0
        queueInfo.queueCount = 1
        var priorities:Float32 = 1
        queueInfo.pQueuePriorities = UnsafePointer(UnsafeMutablePointer(&priorities))
        var deviceInfo = VkDeviceCreateInfo()
        deviceInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
        deviceInfo.pNext = nil
        deviceInfo.flags = 0
        deviceInfo.queueCreateInfoCount = 1
        deviceInfo.pQueueCreateInfos = UnsafePointer(UnsafeMutablePointer(&queueInfo))
        // TODO: add extension 
        var ext = [ VK_KHR_SWAPCHAIN_EXTENSION_NAME ]
        var pext = ext.map { UnsafePointer<Int8>(strdup($0)) }
        deviceInfo.enabledExtensionCount = UInt32(ext.count)
        deviceInfo.ppEnabledExtensionNames = UnsafeRawPointer(pext).assumingMemoryBound(to:UnsafePointer<Int8>?.self)
        deviceInfo.pEnabledFeatures = nil;
        if ll.vkCreateDevice!(device!.physicalDevice, &deviceInfo, nil, &logicalDevice) == VK_SUCCESS {
            NSLog("urdidium: device OK")
        } else {
            NSLog("urdidium: device error")
        }
        for e in pext {
            free(UnsafeMutableRawPointer(mutating:e))
        }
    }
    func createQueue() {
        var i = 0
        for fp in device!.queuesProperties {
            if fp.queueFlags & VK_QUEUE_GRAPHICS_BIT.rawValue != 0 {
                ll.vkGetDeviceQueue!(logicalDevice, UInt32(i), 0, &queue)
                queueIndex = UInt32(i)
                NSLog("urdidium: queue OK")
                break
            }
            i += 1
        }
    }
    func createCommandPool() {
        var cmdPoolInfo=VkCommandPoolCreateInfo()
        cmdPoolInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
        cmdPoolInfo.pNext = nil
        cmdPoolInfo.queueFamilyIndex = queueIndex
        cmdPoolInfo.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT.rawValue
        if ll.vkCreateCommandPool!(logicalDevice, &cmdPoolInfo, nil, &commandPool) == VK_SUCCESS {
            NSLog("urdidium: Command Pool OK")
        }
    }
}

func iterate<C>(_ t:C, block:(Int,Any)->()) { // itterate tupple
    let mirror = Mirror(reflecting: t)
    for (index,attr) in mirror.children.enumerated() {
        block(index,attr.value)
    }
}

