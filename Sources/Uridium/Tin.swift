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
    public class Device {
        public struct MemoryProperties {
            public var types:[VkMemoryType]
            public var heaps:[VkMemoryHeap]
            public init() {
                types = [VkMemoryType]()
                heaps = [VkMemoryHeap]()
            }
        }
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
        init(device:VkPhysicalDevice, properties p:VkPhysicalDeviceProperties) {
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
            vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &count, nil)
            queuesProperties = [VkQueueFamilyProperties] (repeating:VkQueueFamilyProperties(), count:Int(count))
            vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &count, &queuesProperties)
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
                NSLog("Vulkan: device \(deviceName) queue \(i) \(operation)")
            }
        }
        func enumerateMemoryProperties() {
            var p = VkPhysicalDeviceMemoryProperties()
            vkGetPhysicalDeviceMemoryProperties(physicalDevice, &p)
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
    class Swapchain {
        // TODO:
    }
    class Image {
        var image:VkImage
        var view:VkImageView
        var framebuffer:VkFramebuffer
        var width:Int 
        var height:Int
        init(image:VkImage,view:VkImageView,framebuffer:VkFramebuffer,width:Int,height:Int) {
            self.image = image
            self.view = view
            self.framebuffer = framebuffer
            self.width = width
            self.height = height
        }
    }
    public class CommandBuffer {
        let engine:Tin
        var cb:VkCommandBuffer?
        public init?(engine:Tin) {
            self.engine = engine
            var setupBufferInfo = VkCommandBufferAllocateInfo()
            setupBufferInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
            setupBufferInfo.commandPool = engine.commandPool
            setupBufferInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
            setupBufferInfo.commandBufferCount = 1
            if vkAllocateCommandBuffers(engine.logicalDevice, &setupBufferInfo, &cb) != VK_SUCCESS {
                return nil
            }
            var commandBufferBeginInfo = VkCommandBufferBeginInfo()
            commandBufferBeginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
            if vkBeginCommandBuffer(cb,&commandBufferBeginInfo) != VK_SUCCESS {
                return nil
            }
        }
        public func submit() {  // submit async, for sync version look at vkCreateFence, vkQueueSubmit(,,,fence) 
            vkEndCommandBuffer(cb)
            var submitInfo=VkSubmitInfo()
            submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO
            submitInfo.commandBufferCount = 1
            submitInfo.pCommandBuffers = UnsafePointer(UnsafeMutablePointer(&cb))
            vkQueueSubmit(engine.queue, 1, &submitInfo, nil)
        }
        deinit {
            vkQueueWaitIdle(engine.queue)
            vkFreeCommandBuffers(engine.logicalDevice, engine.commandPool, 1, &cb)
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
            vkCmdPipelineBarrier(cb, srcFlags, dstFlags, 0, 0, nil, 0, nil, 1, &imageBarrier);
        }
    }
    public class Texture {
        let engine:Tin
        var needStaging = false
        var image:VkImage?
        var imageLayout:VkImageLayout = VK_IMAGE_LAYOUT_UNDEFINED
        var memory:VkDeviceMemory?
        var view:VkImageView?
        var sampler:VkSampler? 
        let width:Int
        let height:Int
        public init?(engine:Tin,width:Int,height:Int,pixels:[UInt32]? = nil) {
            self.engine = engine
            self.width = width
            self.height = height

            var formatProps = VkFormatProperties()
            vkGetPhysicalDeviceFormatProperties(engine.device!.physicalDevice, VK_FORMAT_R8G8B8A8_UNORM, &formatProps);
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
            if vkCreateImage(engine.logicalDevice, &image_create_info, nil, &mappableImage) != VK_SUCCESS {
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
            if vkAllocateMemory(engine.logicalDevice, &mem_alloc, nil, &mappableMemory) != VK_SUCCESS {
                // TODO: release Image
                return nil
            }
            if vkBindImageMemory(engine.logicalDevice, mappableImage, mappableMemory, 0) != VK_SUCCESS {
                // TODO: release Image & Memory
                return nil
            }

            var subres = VkImageSubresource()
            subres.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
            subres.mipLevel = 0
            subres.arrayLayer = 0
            var layout = VkSubresourceLayout()
            vkGetImageSubresourceLayout(engine.logicalDevice, mappableImage, &subres, &layout);
            if let pixels = pixels {
                var data : UnsafeMutableRawPointer?
                if vkMapMemory(engine.logicalDevice, mappableMemory, 0, mem_reqs.size, 0, UnsafeMutablePointer(&data)) == VK_SUCCESS {
                    memcpy(data!,pixels,4*width*height)
                    vkUnmapMemory(engine.logicalDevice, mappableMemory)
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
                    if vkCreateImage(engine.logicalDevice, &image_create_info, nil, &self.image) != VK_SUCCESS {
                        // TODO: clear...
                        return nil
                    }
                    vkGetImageMemoryRequirements(engine.logicalDevice, self.image, &mem_reqs)
                    mem_alloc.allocationSize = mem_reqs.size
                    if let i = engine.device?.memoryTypeIndex(typeBits:mem_reqs.memoryTypeBits,requirements: VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT.rawValue | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT.rawValue) {
                        mem_alloc.memoryTypeIndex = i
                    } else {
                        // TODO: clear...
                        return nil
                    }
                    if vkAllocateMemory(engine.logicalDevice, &mem_alloc, nil, &self.memory) != VK_SUCCESS {
                        // TODO: clear...
                        return nil
                    }
                    if vkBindImageMemory(engine.logicalDevice, self.image, self.memory, 0) != VK_SUCCESS {
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
                    vkCmdCopyImage(cb.cb!, mappableImage!, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, self.image!, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &copy_region)
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
            if vkCreateSampler(engine.logicalDevice, &samplerCreateInfo, nil, &self.sampler) != VK_SUCCESS {
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
            if vkCreateImageView(engine.logicalDevice, &view_info, nil, &self.view) != VK_SUCCESS {
                // TODO: clear...
                return nil
            }
            if self.needStaging {
                vkFreeMemory(engine.logicalDevice, mappableMemory, nil)
                vkDestroyImage(engine.logicalDevice, mappableImage, nil)                
            }
        }
        deinit {
            if sampler != nil {
                vkDestroySampler(engine.logicalDevice,sampler,nil)
                sampler = nil
            }
            if view != nil {
                vkDestroyImageView(engine.logicalDevice,view,nil)
                view = nil
            }
            if image != nil {
                vkDestroyImage(engine.logicalDevice,image,nil)
                image = nil
            }
            if memory != nil {
                vkFreeMemory(engine.logicalDevice,memory,nil)
                memory = nil
            }
        }
    }
    public class RenderCommandEncoder {
        public init() {
        }
    }
    public class RenderPass {
        let engine:Tin
        var renderPass:VkRenderPass?
        var cb:CommandBuffer?
        init?(engine:Tin, to image:Image) {
            self.engine = engine
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
            if vkCreateRenderPass(engine.logicalDevice, &renderPassInfo, nil, &renderPass) != VK_SUCCESS {
                return nil
            }
            begin(width:image.width,height:image.height,framebuffer:image.framebuffer)
        }
        public init(engine:Tin, to texture:Texture) {
            self.engine = engine
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
            vkCmdBeginRenderPass(cb!.cb, &rp_begin, VK_SUBPASS_CONTENTS_INLINE);
        }
    }
    public class Pipeline {
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
        let engine:Tin
        var vertex : VkShaderModule?
        var fragment : VkShaderModule?
        var pipeline:VkPipeline?
        public init(engine:Tin,vertex:String,fragment:String,format:[VertexFormat]) {
            self.engine = engine
            self.vertex = createShaderModule(code:vertex)
            self.fragment = createShaderModule(code:fragment)
            self.createPipeline(format:format)
        }
        func createShaderModule(code:String) -> VkShaderModule? {
            var createInfo = VkShaderModuleCreateInfo()
            createInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
            // TODO:
            //createInfo.codeSize = code.length
            //createInfo.pCode = code
            var shader : VkShaderModule?
            vkCreateShaderModule(engine.logicalDevice,&createInfo,nil,&shader)
            return shader
        }
        func createPipeline(format:[VertexFormat]) {
            func fStages() -> [VkPipelineShaderStageCreateInfo] {
                var infoVertex = VkPipelineShaderStageCreateInfo()
                infoVertex.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
                infoVertex.stage = VK_SHADER_STAGE_VERTEX_BIT
                infoVertex.pName = UnsafeRawPointer("vertex").assumingMemoryBound(to:Int8.self)
                infoVertex.module = self.vertex
                var infoFragment = VkPipelineShaderStageCreateInfo()
                infoFragment.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
                infoFragment.stage = VK_SHADER_STAGE_FRAGMENT_BIT
                infoFragment.pName = UnsafeRawPointer("fragment").assumingMemoryBound(to:Int8.self)
                infoFragment.module = self.fragment
                return [infoVertex,infoFragment]
            }
            func fVertexInput(format:[VertexFormat]) -> VkPipelineVertexInputStateCreateInfo {
                var vertexInputInfo = VkPipelineVertexInputStateCreateInfo()
                vertexInputInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
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
                vertexInputInfo.vertexAttributeDescriptionCount = UInt32(attributes.count)
                vertexInputInfo.pVertexAttributeDescriptions = UnsafePointer(UnsafeMutablePointer(&attributes))
                var binding = VkVertexInputBindingDescription()
                binding.binding = 0
                binding.stride = UInt32(size)
                binding.inputRate = VK_VERTEX_INPUT_RATE_VERTEX
                vertexInputInfo.vertexBindingDescriptionCount = 1
                vertexInputInfo.pVertexBindingDescriptions = UnsafePointer(UnsafeMutablePointer(&binding))
                return vertexInputInfo
            }
            func fAssembly() -> VkPipelineInputAssemblyStateCreateInfo {
                var assembly = VkPipelineInputAssemblyStateCreateInfo()
                assembly.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
                assembly.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST // VkPrimitiveTopology
                assembly.primitiveRestartEnable = VkBool32(VK_FALSE)
                return assembly
            }
            func fViewports() -> VkPipelineViewportStateCreateInfo {
                var vsci = VkPipelineViewportStateCreateInfo()
                vsci.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO
                var vps = [VkViewport]()
                var vp = VkViewport()  
                vp.x = -1
                vp.y = 1
                vp.width = 2
                vp.height = 2
                vp.minDepth = 0
                vp.maxDepth = 1
                vps.append(vp)
                vsci.viewportCount = UInt32(vps.count)
                vsci.pViewports = UnsafePointer(UnsafeMutablePointer(&vps))
                return vsci
            }
            func fRasterization() -> VkPipelineRasterizationStateCreateInfo {
                var rsci = VkPipelineRasterizationStateCreateInfo()
                rsci.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
                rsci.depthClampEnable = VkBool32(VK_TRUE)
                rsci.rasterizerDiscardEnable = VkBool32(VK_TRUE)
                rsci.polygonMode = VK_POLYGON_MODE_FILL         // VkPolygonMode
                rsci.cullMode = VK_CULL_MODE_BACK_BIT.rawValue  // VkCullModeFlagBits
                rsci.frontFace = VK_FRONT_FACE_CLOCKWISE        // VkFrontFace
                rsci.depthBiasEnable = VkBool32(VK_FALSE)
                rsci.lineWidth = 0  // ???
                return rsci
            }
            func fMultisample() -> VkPipelineMultisampleStateCreateInfo {
                // https://www.khronos.org/registry/vulkan/specs/1.0/html/vkspec.html#primsrast-sampleshading
                var msci = VkPipelineMultisampleStateCreateInfo()
                msci.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
                msci.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT   // VkSampleCountFlagBits
                msci.sampleShadingEnable = VkBool32(VK_FALSE)
                msci.minSampleShading = 1
                msci.pSampleMask = nil
                msci.alphaToCoverageEnable = VkBool32(VK_FALSE)
                msci.alphaToOneEnable = VkBool32(VK_FALSE)
                return msci
            }
            func fDepthStencil() -> VkPipelineDepthStencilStateCreateInfo {
                var dsci = VkPipelineDepthStencilStateCreateInfo()
                dsci.sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO
                dsci.depthTestEnable = VkBool32(VK_FALSE)   // TODO: enable depth test
                dsci.depthWriteEnable = VkBool32(VK_FALSE)
                dsci.depthCompareOp = VK_COMPARE_OP_LESS
                dsci.depthBoundsTestEnable = VkBool32(VK_FALSE)
                dsci.stencilTestEnable = VkBool32(VK_FALSE)
                // dsci.front =
                // dsci.back =
                dsci.minDepthBounds = 0
                dsci.maxDepthBounds = 1
                return dsci
            }
            func fBlend() -> VkPipelineColorBlendStateCreateInfo {
                // https://www.khronos.org/registry/vulkan/specs/1.0/man/html/VkPipelineColorBlendStateCreateInfo.html
                var bsci = VkPipelineColorBlendStateCreateInfo()
                bsci.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO
                bsci.logicOpEnable = VkBool32(VK_FALSE)
                bsci.logicOp = VK_LOGIC_OP_SET                  // VkLogicOp, special blend (or,and,xor..)
                bsci.attachmentCount = 1
                var att = VkPipelineColorBlendAttachmentState()
                att.blendEnable = VkBool32(VK_FALSE)            // TODO: ennable blend
                att.srcColorBlendFactor = VK_BLEND_FACTOR_ONE   // VkBlendFactor
                att.dstColorBlendFactor = VK_BLEND_FACTOR_ONE
                att.colorBlendOp = VK_BLEND_OP_ADD
                att.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE
                att.dstAlphaBlendFactor  = VK_BLEND_FACTOR_ONE
                att.alphaBlendOp = VK_BLEND_OP_MAX
                att.colorWriteMask = VK_COLOR_COMPONENT_R_BIT.rawValue | VK_COLOR_COMPONENT_G_BIT.rawValue | VK_COLOR_COMPONENT_B_BIT.rawValue | VK_COLOR_COMPONENT_A_BIT.rawValue
                bsci.pAttachments = UnsafePointer(UnsafeMutablePointer(&att))
                bsci.blendConstants.0 = 1.0 // R
                bsci.blendConstants.1 = 1.0 // G
                bsci.blendConstants.2 = 1.0 // B
                bsci.blendConstants.3 = 1.0 // A
                return bsci
            }
            func fDynamic() -> VkPipelineDynamicStateCreateInfo {
                var dsci = VkPipelineDynamicStateCreateInfo()
                dsci.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
                var dyn = [VkDynamicState]()
                // dyn.append(VK_DYNAMIC_STATE_SCISSOR)
                dsci.dynamicStateCount = UInt32(dyn.count)
                dsci.pDynamicStates = UnsafePointer(UnsafeMutablePointer(&dyn))
                return dsci
            }
            var pipelineInfo = VkGraphicsPipelineCreateInfo()
            pipelineInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO            
            var stages = fStages()
            pipelineInfo.stageCount = UInt32(stages.count)
            pipelineInfo.pStages = UnsafePointer(UnsafeMutablePointer(&stages))
            var vertexInput = fVertexInput(format:format)
            pipelineInfo.pVertexInputState = UnsafePointer(UnsafeMutablePointer(&vertexInput))
            var assembly = fAssembly()
            pipelineInfo.pInputAssemblyState = UnsafePointer(UnsafeMutablePointer(&assembly))
            var viewports = fViewports()
            pipelineInfo.pViewportState = UnsafePointer(UnsafeMutablePointer(&viewports))
            var rasterization = fRasterization()
            pipelineInfo.pRasterizationState = UnsafePointer(UnsafeMutablePointer(&rasterization))
            var multisample = fMultisample()
            pipelineInfo.pMultisampleState = UnsafePointer(UnsafeMutablePointer(&multisample))
            var depthstencil = fDepthStencil()
            pipelineInfo.pDepthStencilState = UnsafePointer(UnsafeMutablePointer(&depthstencil))
            var blend = fBlend()
            pipelineInfo.pColorBlendState = UnsafePointer(UnsafeMutablePointer(&blend))
            var dynamic = fDynamic()
            pipelineInfo.pDynamicState = UnsafePointer(UnsafeMutablePointer(&dynamic))
            vkCreateGraphicsPipelines(engine.logicalDevice,nil,1, &pipelineInfo,nil,&pipeline)
        }
    }
    public class Buffer {
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
        var engine:Tin
        var buffer:VkBuffer?
        var memory:VkDeviceMemory?
        public init?(engine:Tin,size:Int,usage:Usage) {
            self.engine = engine
            var ci = VkBufferCreateInfo()
            ci.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO
            ci.size = UInt64(size)
            ci.usage = UInt32(usage.rawValue)
            ci.sharingMode = VK_SHARING_MODE_EXCLUSIVE
            if vkCreateBuffer(engine.logicalDevice, &ci, nil, &buffer) != VK_SUCCESS {
                return nil
            }
            var memRequirements = VkMemoryRequirements()
            vkGetBufferMemoryRequirements(engine.logicalDevice, buffer, &memRequirements)
            var allocInfo = VkMemoryAllocateInfo()
            allocInfo.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO
            allocInfo.allocationSize = memRequirements.size
            allocInfo.memoryTypeIndex = 0
            if vkAllocateMemory(engine.logicalDevice, &allocInfo, nil, &memory) != VK_SUCCESS {
                return nil
            }
            vkBindBufferMemory(engine.logicalDevice, buffer, memory, 0);            
        }
        deinit {
            if memory != nil {
                vkFreeMemory(engine.logicalDevice,memory,nil)
                memory = nil
            }
            if buffer != nil {
                vkDestroyBuffer(engine.logicalDevice, buffer, nil)
                buffer = nil
            }
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
    var surface:VkSurfaceKHR?=nil
    var devices=[Device]()
    var device:Device?
    var logicalDevice:VkDevice? 
    var swapchain:VkSwapchainKHR?
    var commandPool:VkCommandPool?
    var images=[Image]()
    var queue:VkQueue?
    var queueIndex:UInt32 = 0
    var imageIndex:UInt32=0

    init(window:Window) {
        self.window = window
        if createInstance(app:window.title) {
            enumerateDevices()
            createDevice(0)
            createQueue()
            createCommandPool()
            createSurface()
            createSwapchain()
        }
    }
    deinit {
        NSLog("Vulkan: destroy")
        if let device = logicalDevice {
            vkDeviceWaitIdle(device)
        }
        if instance != nil {
            if swapchain != nil {
                destroySwapchain()
                swapchain = nil
            }
            NSLog("Vulkan: swapchain destroyed")
            if logicalDevice != nil {
                vkDestroyDevice(logicalDevice, nil)
                logicalDevice = nil
            }
            NSLog("Vulkan: device destroyed")
            if surface != nil {
                vkDestroySurfaceKHR(instance,surface,nil)
                surface = nil
            }
            NSLog("Vulkan: surface destroyed")
            vkDestroyInstance(instance,nil)
            instance = nil
            NSLog("Vulkan: instance destroyed")
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
        appInfo.pApplicationName = UnsafePointer(strdup(app))
        appInfo.pEngineName = UnsafePointer(strdup("uridium"))
        var icInfo = VkInstanceCreateInfo()
        icInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
        icInfo.pNext = nil
        icInfo.flags = 0
        let ext = [ UnsafePointer(strdup(VK_KHR_SURFACE_EXTENSION_NAME)), UnsafePointer(strdup(VK_KHR_XCB_SURFACE_EXTENSION_NAME))]
        var result : VkResult = VK_INCOMPLETE
        ext.withUnsafeBufferPointer { pext in
            icInfo.enabledExtensionCount = UInt32(pext.count)
            icInfo.ppEnabledExtensionNames = pext.baseAddress
            icInfo.pApplicationInfo = UnsafePointer(UnsafeMutablePointer(&appInfo))
            result = vkCreateInstance(&icInfo,nil,&instance)
            switch result {
                case VK_ERROR_INCOMPATIBLE_DRIVER:
                NSLog("Vulkan: Incompatible driver")
                case VK_SUCCESS:
                NSLog("Vulkan: Instance OK")
                default:
                NSLog("Vulkan: Instance error: \(result)")
            }
        }
        free(UnsafeMutableRawPointer(mutating:appInfo.pApplicationName))
        free(UnsafeMutableRawPointer(mutating:appInfo.pEngineName))
        free(UnsafeMutableRawPointer(mutating:ext[0]))
        free(UnsafeMutableRawPointer(mutating:ext[1]))
        return result == VK_SUCCESS
    }
    func createSurface() {
        var scinfo = VkXcbSurfaceCreateInfoKHR()
        scinfo.sType = VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR
        scinfo.pNext = nil
        scinfo.flags = 0
        scinfo.connection = window.connection
        scinfo.window = window.windowId
        let result = vkCreateXcbSurfaceKHR(instance, &scinfo, nil, &surface)
        switch result {
            case VK_SUCCESS:
            NSLog("Vulkan: Surface OK")
            default:
            NSLog("Vulkan: Surface error: \(result)")
        }
    }
    func enumerateDevices() {
        var deviceCount:UInt32 = 0
        var result = vkEnumeratePhysicalDevices(instance, &deviceCount, nil)
        if result == VK_SUCCESS && deviceCount>0 {
            var dev = [VkPhysicalDevice?](repeating:nil, count:Int(deviceCount))
            result = vkEnumeratePhysicalDevices(instance, &deviceCount, &dev)
            if result == VK_SUCCESS {
                NSLog("Vulkan: found \(deviceCount) device")
                for i in 0..<Int(deviceCount) {
                    var prop = VkPhysicalDeviceProperties()
                    vkGetPhysicalDeviceProperties(dev[i],&prop)
                    let p = Device(device: dev[i]!, properties:prop)
                    devices.append(p)
                    NSLog("Vulkan: device \(p.deviceName)")
                }
            }
        } else {
            NSLog("Vulkan: error \(result), no device")
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
        deviceInfo.enabledExtensionCount = 0
        deviceInfo.ppEnabledExtensionNames = nil
        deviceInfo.pEnabledFeatures = nil;
        if vkCreateDevice(device!.physicalDevice, &deviceInfo, nil, &logicalDevice) == VK_SUCCESS {
            NSLog("Vulkan: device OK")
        }
    }
    func createQueue() {
        var i = 0
        for fp in device!.queuesProperties {
            if fp.queueFlags & VK_QUEUE_GRAPHICS_BIT.rawValue != 0 {
                vkGetDeviceQueue(logicalDevice, UInt32(i), 0, &queue)
                queueIndex = UInt32(i)
                NSLog("Vulkan: queue OK")
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
        if vkCreateCommandPool(logicalDevice, &cmdPoolInfo, nil, &commandPool) == VK_SUCCESS {
            NSLog("Vulkan: Command Pool OK")
        }
    }
    func createSwapchain() {
        var caps = VkSurfaceCapabilitiesKHR()
        if vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device!.physicalDevice,surface,&caps) == VK_SUCCESS {
            var size = VkExtent2D()
            if caps.currentExtent.width == 0xFFFFFFFF || caps.currentExtent.height == 0xFFFFFFFF {
                size.width = UInt32(window.width)
                size.height = UInt32(window.height)
            } else {
                size = caps.currentExtent
            }
            var presentModeCount : UInt32 = 0
            var presentModes = [VkPresentModeKHR]()
            if vkGetPhysicalDeviceSurfacePresentModesKHR(device!.physicalDevice,surface,&presentModeCount,nil) == VK_SUCCESS && presentModeCount>0 {
                presentModes = [VkPresentModeKHR](repeating:VK_PRESENT_MODE_MAX_ENUM_KHR,count:Int(presentModeCount))
                vkGetPhysicalDeviceSurfacePresentModesKHR(device!.physicalDevice,surface,&presentModeCount,&presentModes)
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
            swapchainCreateInfo.surface = surface
            swapchainCreateInfo.minImageCount = 2
            swapchainCreateInfo.imageFormat = VK_FORMAT_B8G8R8A8_UNORM
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
            if vkCreateSwapchainKHR(logicalDevice, &swapchainCreateInfo, nil, &swapchain) == VK_SUCCESS {
                let mode = pmode == VK_PRESENT_MODE_FIFO_KHR ? "mode: fifo" : ""
                NSLog("Vulkan: swapchain OK, \(mode)")
                var imageCount:UInt32 = 0
                if vkGetSwapchainImagesKHR(logicalDevice, swapchain, &imageCount, nil) == VK_SUCCESS {
                    var images = [VkImage?](repeating:nil,count:Int(imageCount))
                    if vkGetSwapchainImagesKHR(logicalDevice, swapchain, &imageCount, &images) == VK_SUCCESS {
                        if let cb = CommandBuffer(engine:self) {
                            for image in images {
                                cb.setImageLayout(image:image!,aspects:VK_IMAGE_ASPECT_COLOR_BIT.rawValue,oldLayout:VK_IMAGE_LAYOUT_UNDEFINED,newLayout:VK_IMAGE_LAYOUT_PRESENT_SRC_KHR)
                            }
                            cb.submit()
                        }
                        for image in images {
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
                            var view:VkImageView?
                            if vkCreateImageView(logicalDevice, &imageCreateInfo, nil, &view) == VK_SUCCESS {
                                var fbCreateInfo = VkFramebufferCreateInfo()
                                fbCreateInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO
                                fbCreateInfo.attachmentCount = 1
                                fbCreateInfo.pAttachments = UnsafePointer(UnsafeMutablePointer(&view))
                                fbCreateInfo.width = size.width
                                fbCreateInfo.height = size.height
                                fbCreateInfo.layers = 1
                                var framebuffer : VkFramebuffer?
                                if vkCreateFramebuffer(logicalDevice, &fbCreateInfo, nil, &framebuffer) == VK_SUCCESS {
                                    self.images.append(Image(image:image!,view:view!,framebuffer:framebuffer!,width:Int(size.width),height:Int(size.height)))
                                }
                            }
                        }
                        if images.count == self.images.count {
                            NSLog("Vulkan: images OK, count: \(imageCount)")
                        }
                    }
                }
            }
        }
    }
    func destroySwapchain() {
        vkDeviceWaitIdle(logicalDevice)
        for i in images {
            vkDestroyFramebuffer(logicalDevice, i.framebuffer, nil)
            vkDestroyImageView(logicalDevice, i.view, nil)
            // i.image, handled by the swapchain, no destroy...
        }
        images.removeAll()
        vkDestroySwapchainKHR(logicalDevice,swapchain,nil)
    }
    func resizeSwapchain() {
        destroySwapchain()
        createSwapchain()
    }
    func aquire() -> Bool {
        vkQueueWaitIdle(queue)
        imageIndex = (imageIndex + 1) & 1
        if vkAcquireNextImageKHR(logicalDevice,swapchain,100000000,nil,nil,&imageIndex) == VK_SUCCESS {
            return true
        }
        return false
    }
    func present() -> Bool {
        if let queue = queue {
            var presentInfo = VkPresentInfoKHR()
            presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
            presentInfo.pNext = nil
            presentInfo.swapchainCount = 1
            presentInfo.pSwapchains = UnsafePointer(UnsafeMutablePointer(&swapchain))
            presentInfo.pImageIndices = UnsafePointer(UnsafeMutablePointer(&imageIndex))
            if vkQueuePresentKHR(queue, &presentInfo) == VK_SUCCESS {
                return true
            }
        }
        return false
    }
}

func iterate<C>(_ t:C, block:(Int,Any)->()) { // itterate tupple
    let mirror = Mirror(reflecting: t)
    for (index,attr) in mirror.children.enumerated() {
        block(index,attr.value)
    }
}

