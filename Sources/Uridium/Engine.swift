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

    public struct DeviceProperties {
        public var apiVersion:Int
        public var driverVersion:Int
        public var vendorID:Int
        public var deviceID:Int
        public var deviceType:VkPhysicalDeviceType
        public var deviceName:String
        public var limits:VkPhysicalDeviceLimits
        public var sparseProperties:VkPhysicalDeviceSparseProperties
        init(_ p:VkPhysicalDeviceProperties) {
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

    var window:Window
    var instance:VkInstance? = nil
    var surface:VkSurfaceKHR? = nil
    var devices = [VkPhysicalDevice?]()
    var devicesProperties = [DeviceProperties]()
    var deviceLogical : VkDevice? 
    var devicePhysical : VkPhysicalDevice?
    var deviceProperties : DeviceProperties?
    var swapchain:VkSwapchainKHR?
    var images = [VkImage?]()
    var imageViews = [VkImageView?]()
    var queue : VkQueue?
    var imageIndex : UInt32 = 0

    init(window:Window) {
        self.window = window
        if createInstance(app:window.title) {
            enumerateDevices()
            initializeDevice(0)
            createSurface()
            createSwapchain()
        }
    }
    deinit {
        NSLog("Vulkan: destroy")
        if instance != nil {
            /*
            for (SwapChainBuffer buffer : buffers)
                vkDestroyImageView(device, buffer.view, NULL);            
            */
            if swapchain != nil {
                vkDestroySwapchainKHR(deviceLogical,swapchain,nil)
                swapchain = nil
            }
            if surface != nil {
                vkDestroySurfaceKHR(instance,surface,nil)
                surface = nil
            }
            vkDestroyInstance(instance,nil)
            instance = nil
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
    func enumerateDevices() {
        var deviceCount:UInt32 = 0
        var result = vkEnumeratePhysicalDevices(instance, &deviceCount, nil)
        if result == VK_SUCCESS && deviceCount>0 {
            let pdev = UnsafeMutablePointer<VkPhysicalDevice?>.allocate(capacity:Int(deviceCount))
            result = vkEnumeratePhysicalDevices(instance, &deviceCount, pdev)
            if result == VK_SUCCESS {
                NSLog("Vulkan: found \(deviceCount) device")
                for i in 0..<Int(deviceCount) {
                    devices.append(pdev[i])
                    var prop = VkPhysicalDeviceProperties()
                    vkGetPhysicalDeviceProperties(pdev[i],&prop)
                    let p = DeviceProperties(prop)
                    devicesProperties.append(p)
                    NSLog("Vulkan: device \(p.deviceName)")
                }
            }
            pdev.deallocate(capacity:Int(deviceCount))
        } else {
            NSLog("Vulkan: error \(result), no device")
        }
    }
    func initializeDevice(_ idev:Int) {
        devicePhysical = devices[idev]
        deviceProperties = devicesProperties[idev]
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
        if vkCreateDevice(devicePhysical, &deviceInfo, nil, &deviceLogical) == VK_SUCCESS {
            NSLog("Vulkan: device OK")
        }
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
    func setImageLayout(cmdBuffer:VkCommandBuffer,image:VkImage,aspects:VkImageAspectFlags,oldLayout:VkImageLayout,newLayout:VkImageLayout) {
        //var oldLayout = VK_IMAGE_LAYOUT_UNDEFINED
        //var newLayout = VK_IMAGE_LAYOUT_UNDEFINED
        var imageBarrier = VkImageMemoryBarrier()
        imageBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        imageBarrier.pNext = nil
        imageBarrier.oldLayout = oldLayout
        imageBarrier.newLayout = newLayout
        imageBarrier.image = images[0]
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
    }
    func createSwapchain() {
        var caps = VkSurfaceCapabilitiesKHR()
        if vkGetPhysicalDeviceSurfaceCapabilitiesKHR(devicePhysical,surface, &caps) == VK_SUCCESS {
            var r = VkExtent2D()
            if caps.currentExtent.width == 0xFFFFFFFF || caps.currentExtent.height == 0xFFFFFFFF {
                r.width = UInt32(window.width)
                r.height = UInt32(window.height)
            } else {
                r = caps.currentExtent
            }
            var presentModeCount : UInt32 = 0
            var presentModes = [VkPresentModeKHR]()
            if vkGetPhysicalDeviceSurfacePresentModesKHR(devicePhysical,surface,&presentModeCount,nil) == VK_SUCCESS && presentModeCount>0 {
                presentModes = [VkPresentModeKHR](repeating:VK_PRESENT_MODE_MAX_ENUM_KHR,count:Int(presentModeCount))
                vkGetPhysicalDeviceSurfacePresentModesKHR(devicePhysical,surface,&presentModeCount,&presentModes)
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
            swapchainCreateInfo.imageExtent = r
            swapchainCreateInfo.imageArrayLayers = 1
            swapchainCreateInfo.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue
            swapchainCreateInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE
            swapchainCreateInfo.queueFamilyIndexCount = 1
            var indice : UInt32 = 0
            swapchainCreateInfo.pQueueFamilyIndices = UnsafePointer(UnsafeMutablePointer(&indice))
            swapchainCreateInfo.preTransform = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR
            swapchainCreateInfo.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
            swapchainCreateInfo.presentMode = pmode
            if vkCreateSwapchainKHR(deviceLogical, &swapchainCreateInfo, nil, &swapchain) == VK_SUCCESS {
                let mode = pmode == VK_PRESENT_MODE_FIFO_KHR ? "mode: fifo" : ""
                NSLog("Vulkan: swapchain OK, \(mode)")
                var imageCount:UInt32 = 0
                if vkGetSwapchainImagesKHR(deviceLogical, swapchain, &imageCount, nil) == VK_SUCCESS {
                    images = [VkImage?](repeating:nil,count:Int(imageCount))
                    if vkGetSwapchainImagesKHR(deviceLogical, swapchain, &imageCount, &images) == VK_SUCCESS {
                        NSLog("Vulkan: images OK, count: \(imageCount)")
                        for i in images {
                            //setImageLayout(cmdBuffer, i, VK_IMAGE_ASPECT_COLOR_BIT, VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_PRESENT_SRC_KHR)
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
                            imageCreateInfo.image = i
                            var view:VkImageView? = nil
                            if vkCreateImageView(deviceLogical, &imageCreateInfo, nil, &view) == VK_SUCCESS {
                                imageViews.append(view)
                            }
                        }
                    }
                }
            }
        }
    }
    func aquire() -> Bool {
        imageIndex = (imageIndex + 1) & 1
        if vkAcquireNextImageKHR(deviceLogical,swapchain,100000000,nil,nil,&imageIndex) == VK_SUCCESS {
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
