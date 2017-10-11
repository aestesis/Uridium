//
//  Uridium.swift
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

public class Engine {

    public class Device {
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
        }
    }
    class Image {
        var image:VkImage
        var view:VkImageView
        var framebuffer:VkFramebuffer
        init(image:VkImage,view:VkImageView,framebuffer:VkFramebuffer) {
            self.image = image
            self.view = view
            self.framebuffer = framebuffer
        }
    }
    public class CommandBuffer {
        let engine:Engine
        var cb:VkCommandBuffer?
        public init?(engine:Engine) {
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
        public func submit() {
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
        func setImageLayout(image:VkImage,aspects:VkImageAspectFlags,oldLayout:VkImageLayout,newLayout:VkImageLayout) {
            var imageBarrier = VkImageMemoryBarrier()
            imageBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
            imageBarrier.pNext = nil
            imageBarrier.oldLayout = oldLayout
            imageBarrier.newLayout = newLayout
            imageBarrier.image = image
            imageBarrier.subresourceRange.aspectMask = 0
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
            let srcFlags:VkPipelineStageFlags  = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT.rawValue
            let dstFlags:VkPipelineStageFlags  = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT.rawValue
            vkCmdPipelineBarrier(cb, srcFlags, dstFlags, 0, 0, nil, 0, nil, 1, &imageBarrier);
        }
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
            enumerateQueues()
            createDevice(0)
            createQueue()
            createCommandPool()
            createSurface()
            createSwapchain()
        }
    }
    deinit {
        NSLog("Vulkan: destroy")
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
        appInfo.pApplicationName = UnsafePointer<Int8>(strdup(app))
        appInfo.pEngineName = UnsafePointer<Int8>(strdup("uridium"))
        var icInfo = VkInstanceCreateInfo()
        icInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
        icInfo.pNext = nil
        icInfo.flags = 0
        let ext = [ UnsafePointer(strdup(VK_KHR_SURFACE_EXTENSION_NAME)), UnsafePointer(strdup(VK_KHR_XCB_SURFACE_EXTENSION_NAME))]
        var result : VkResult = VK_INCOMPLETE
        ext.withUnsafeBufferPointer { pext in
            icInfo.enabledExtensionCount = UInt32(pext.count)
            icInfo.ppEnabledExtensionNames = pext.baseAddress
            icInfo.pApplicationInfo = UnsafePointer(UnsafeMutablePointer<VkApplicationInfo>(mutating:&appInfo))
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
    func enumerateQueues() {
        var idev = 0
        for d in devices {
            var count : UInt32 = 0
            vkGetPhysicalDeviceQueueFamilyProperties(d.physicalDevice, &count, nil)
            var qfp = [VkQueueFamilyProperties] (repeating:VkQueueFamilyProperties(), count:Int(count))
            vkGetPhysicalDeviceQueueFamilyProperties(d.physicalDevice, &count, &qfp)
            d.queuesProperties = qfp
            for i in 0..<Int(count) {
                let fp = qfp[i]
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
                NSLog("Vulkan: device \(d.deviceName) queue \(i) \(operation)")
            }
            idev += 1
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
                            NSLog("Vulkan: command buffer for images layout OK")
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
                                    self.images.append(Image(image:image!,view:view!,framebuffer:framebuffer!))
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
            vkDestroyImage(logicalDevice, i.image, nil)
        }
        images.removeAll()
        vkDestroySwapchainKHR(logicalDevice,swapchain,nil)
    }
    func resizeSwapchain() {
        destroySwapchain()
        createSwapchain()
    }
    func aquire() -> Bool {
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
