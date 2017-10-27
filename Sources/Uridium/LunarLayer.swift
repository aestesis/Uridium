import Vulkan
import Foundation

class LunarLayer {   // VK_LAYER_LUNARG_standard_validation
    // https://gpuopen.com/using-the-vulkan-validation-layers/
    // https://vulkan.lunarg.com/doc/view/1.0.57.0/linux/LoaderAndLayerInterface.html
    // https://linux.die.net/man/3/dlsym
    // https://github.com/MrVallentin/vkel/blob/master/vkel.c
    // https://github.com/KhronosGroup/Vulkan-Docs/tree/1.0/src/ext_loader
    var lunar : Bool {
        return h != nil
    }
    var h : UnsafeMutableRawPointer?

    var vkAcquireNextImageKHR:PFN_vkAcquireNextImageKHR?
    var vkAllocateCommandBuffers:PFN_vkAllocateCommandBuffers?
    var vkAllocateDescriptorSets:PFN_vkAllocateDescriptorSets?
    var vkAllocateMemory:PFN_vkAllocateMemory?
    var vkAllocationFunction:PFN_vkAllocationFunction?
    var vkBeginCommandBuffer:PFN_vkBeginCommandBuffer?
    var vkBindBufferMemory:PFN_vkBindBufferMemory?
    var vkBindImageMemory:PFN_vkBindImageMemory?
    var vkCmdBeginQuery:PFN_vkCmdBeginQuery?
    var vkCmdBeginRenderPass:PFN_vkCmdBeginRenderPass?
    var vkCmdBindDescriptorSets:PFN_vkCmdBindDescriptorSets?
    var vkCmdBindIndexBuffer:PFN_vkCmdBindIndexBuffer?
    var vkCmdBindPipeline:PFN_vkCmdBindPipeline?
    var vkCmdBindVertexBuffers:PFN_vkCmdBindVertexBuffers?
    var vkCmdBlitImage:PFN_vkCmdBlitImage?
    var vkCmdClearAttachments:PFN_vkCmdClearAttachments?
    var vkCmdClearColorImage:PFN_vkCmdClearColorImage?
    var vkCmdClearDepthStencilImage:PFN_vkCmdClearDepthStencilImage?
    var vkCmdCopyBuffer:PFN_vkCmdCopyBuffer?
    var vkCmdCopyBufferToImage:PFN_vkCmdCopyBufferToImage?
    var vkCmdCopyImage:PFN_vkCmdCopyImage?
    var vkCmdCopyImageToBuffer:PFN_vkCmdCopyImageToBuffer?
    var vkCmdCopyQueryPoolResults:PFN_vkCmdCopyQueryPoolResults?
    var vkCmdDebugMarkerBeginEXT:PFN_vkCmdDebugMarkerBeginEXT?
    var vkCmdDebugMarkerEndEXT:PFN_vkCmdDebugMarkerEndEXT?
    var vkCmdDebugMarkerInsertEXT:PFN_vkCmdDebugMarkerInsertEXT?
    var vkCmdDispatch:PFN_vkCmdDispatch?
    var vkCmdDispatchIndirect:PFN_vkCmdDispatchIndirect?
    var vkCmdDraw:PFN_vkCmdDraw?
    var vkCmdDrawIndexed:PFN_vkCmdDrawIndexed?
    var vkCmdDrawIndexedIndirect:PFN_vkCmdDrawIndexedIndirect?
    var vkCmdDrawIndirect:PFN_vkCmdDrawIndirect?
    var vkCmdEndQuery:PFN_vkCmdEndQuery?
    var vkCmdEndRenderPass:PFN_vkCmdEndRenderPass?
    var vkCmdExecuteCommands:PFN_vkCmdExecuteCommands?
    var vkCmdFillBuffer:PFN_vkCmdFillBuffer?
    var vkCmdNextSubpass:PFN_vkCmdNextSubpass?
    var vkCmdPipelineBarrier:PFN_vkCmdPipelineBarrier?
    var vkCmdPushConstants:PFN_vkCmdPushConstants?
    var vkCmdResetEvent:PFN_vkCmdResetEvent?
    var vkCmdResetQueryPool:PFN_vkCmdResetQueryPool?
    var vkCmdResolveImage:PFN_vkCmdResolveImage?
    var vkCmdSetBlendConstants:PFN_vkCmdSetBlendConstants?
    var vkCmdSetDepthBias:PFN_vkCmdSetDepthBias?
    var vkCmdSetDepthBounds:PFN_vkCmdSetDepthBounds?
    var vkCmdSetEvent:PFN_vkCmdSetEvent?
    var vkCmdSetLineWidth:PFN_vkCmdSetLineWidth?
    var vkCmdSetScissor:PFN_vkCmdSetScissor?
    var vkCmdSetStencilCompareMask:PFN_vkCmdSetStencilCompareMask?
    var vkCmdSetStencilReference:PFN_vkCmdSetStencilReference?
    var vkCmdSetStencilWriteMask:PFN_vkCmdSetStencilWriteMask?
    var vkCmdSetViewport:PFN_vkCmdSetViewport?
    var vkCmdUpdateBuffer:PFN_vkCmdUpdateBuffer?
    var vkCmdWaitEvents:PFN_vkCmdWaitEvents?
    var vkCmdWriteTimestamp:PFN_vkCmdWriteTimestamp?
    var vkCreateBuffer:PFN_vkCreateBuffer?
    var vkCreateBufferView:PFN_vkCreateBufferView?
    var vkCreateCommandPool:PFN_vkCreateCommandPool?
    var vkCreateComputePipelines:PFN_vkCreateComputePipelines?
    var vkCreateDebugReportCallbackEXT:PFN_vkCreateDebugReportCallbackEXT?
    var vkCreateDescriptorPool:PFN_vkCreateDescriptorPool?
    var vkCreateDescriptorSetLayout:PFN_vkCreateDescriptorSetLayout?
    var vkCreateDevice:PFN_vkCreateDevice?
    var vkCreateDisplayModeKHR:PFN_vkCreateDisplayModeKHR?
    var vkCreateDisplayPlaneSurfaceKHR:PFN_vkCreateDisplayPlaneSurfaceKHR?
    var vkCreateEvent:PFN_vkCreateEvent?
    var vkCreateFence:PFN_vkCreateFence?
    var vkCreateFramebuffer:PFN_vkCreateFramebuffer?
    var vkCreateGraphicsPipelines:PFN_vkCreateGraphicsPipelines?
    var vkCreateImage:PFN_vkCreateImage?
    var vkCreateImageView:PFN_vkCreateImageView?
    var vkCreateInstance:PFN_vkCreateInstance?
    var vkCreatePipelineCache:PFN_vkCreatePipelineCache?
    var vkCreatePipelineLayout:PFN_vkCreatePipelineLayout?
    var vkCreateQueryPool:PFN_vkCreateQueryPool?
    var vkCreateRenderPass:PFN_vkCreateRenderPass?
    var vkCreateSampler:PFN_vkCreateSampler?
    var vkCreateSemaphore:PFN_vkCreateSemaphore?
    var vkCreateShaderModule:PFN_vkCreateShaderModule?
    var vkCreateSharedSwapchainsKHR:PFN_vkCreateSharedSwapchainsKHR?
    var vkCreateSwapchainKHR:PFN_vkCreateSwapchainKHR?
    var vkDebugMarkerSetObjectNameEXT:PFN_vkDebugMarkerSetObjectNameEXT?
    var vkDebugMarkerSetObjectTagEXT:PFN_vkDebugMarkerSetObjectTagEXT?
    var vkDebugReportCallbackEXT:PFN_vkDebugReportCallbackEXT?
    var vkDebugReportMessageEXT:PFN_vkDebugReportMessageEXT?
    var vkDestroyBuffer:PFN_vkDestroyBuffer?
    var vkDestroyBufferView:PFN_vkDestroyBufferView?
    var vkDestroyCommandPool:PFN_vkDestroyCommandPool?
    var vkDestroyDebugReportCallbackEXT:PFN_vkDestroyDebugReportCallbackEXT?
    var vkDestroyDescriptorPool:PFN_vkDestroyDescriptorPool?
    var vkDestroyDescriptorSetLayout:PFN_vkDestroyDescriptorSetLayout?
    var vkDestroyDevice:PFN_vkDestroyDevice?
    var vkDestroyEvent:PFN_vkDestroyEvent?
    var vkDestroyFence:PFN_vkDestroyFence?
    var vkDestroyFramebuffer:PFN_vkDestroyFramebuffer?
    var vkDestroyImage:PFN_vkDestroyImage?
    var vkDestroyImageView:PFN_vkDestroyImageView?
    var vkDestroyInstance:PFN_vkDestroyInstance?
    var vkDestroyPipeline:PFN_vkDestroyPipeline?
    var vkDestroyPipelineCache:PFN_vkDestroyPipelineCache?
    var vkDestroyPipelineLayout:PFN_vkDestroyPipelineLayout?
    var vkDestroyQueryPool:PFN_vkDestroyQueryPool?
    var vkDestroyRenderPass:PFN_vkDestroyRenderPass?
    var vkDestroySampler:PFN_vkDestroySampler?
    var vkDestroySemaphore:PFN_vkDestroySemaphore?
    var vkDestroyShaderModule:PFN_vkDestroyShaderModule?
    var vkDestroySurfaceKHR:PFN_vkDestroySurfaceKHR?
    var vkDestroySwapchainKHR:PFN_vkDestroySwapchainKHR?
    var vkDeviceWaitIdle:PFN_vkDeviceWaitIdle?
    var vkEndCommandBuffer:PFN_vkEndCommandBuffer?
    var vkEnumerateDeviceExtensionProperties:PFN_vkEnumerateDeviceExtensionProperties?
    var vkEnumerateDeviceLayerProperties:PFN_vkEnumerateDeviceLayerProperties?
    var vkEnumerateInstanceExtensionProperties:PFN_vkEnumerateInstanceExtensionProperties?
    var vkEnumerateInstanceLayerProperties:PFN_vkEnumerateInstanceLayerProperties?
    var vkEnumeratePhysicalDevices:PFN_vkEnumeratePhysicalDevices?
    var vkFlushMappedMemoryRanges:PFN_vkFlushMappedMemoryRanges?
    var vkFreeCommandBuffers:PFN_vkFreeCommandBuffers?
    var vkFreeDescriptorSets:PFN_vkFreeDescriptorSets?
    var vkFreeFunction:PFN_vkFreeFunction?
    var vkFreeMemory:PFN_vkFreeMemory? 
    var vkGetBufferMemoryRequirements:PFN_vkGetBufferMemoryRequirements?
    var vkGetDeviceMemoryCommitment:PFN_vkGetDeviceMemoryCommitment?
    var vkGetDeviceProcAddr:PFN_vkGetDeviceProcAddr?
    var vkGetDeviceQueue:PFN_vkGetDeviceQueue?
    var vkGetDisplayModePropertiesKHR:PFN_vkGetDisplayModePropertiesKHR?
    var vkGetDisplayPlaneCapabilitiesKHR:PFN_vkGetDisplayPlaneCapabilitiesKHR?
    var vkGetDisplayPlaneSupportedDisplaysKHR:PFN_vkGetDisplayPlaneSupportedDisplaysKHR?
    var vkGetEventStatus:PFN_vkGetEventStatus?
    var vkGetFenceStatus:PFN_vkGetFenceStatus?
    var vkGetImageMemoryRequirements:PFN_vkGetImageMemoryRequirements?
    var vkGetImageSparseMemoryRequirements:PFN_vkGetImageSparseMemoryRequirements?
    var vkGetImageSubresourceLayout:PFN_vkGetImageSubresourceLayout?
    var vkGetInstanceProcAddr:PFN_vkGetInstanceProcAddr?
    var vkGetPhysicalDeviceDisplayPlanePropertiesKHR:PFN_vkGetPhysicalDeviceDisplayPlanePropertiesKHR?
    var vkGetPhysicalDeviceDisplayPropertiesKHR:PFN_vkGetPhysicalDeviceDisplayPropertiesKHR?
    var vkGetPhysicalDeviceFeatures:PFN_vkGetPhysicalDeviceFeatures?
    var vkGetPhysicalDeviceFormatProperties:PFN_vkGetPhysicalDeviceFormatProperties?
    var vkGetPhysicalDeviceImageFormatProperties:PFN_vkGetPhysicalDeviceImageFormatProperties?
    var vkGetPhysicalDeviceMemoryProperties:PFN_vkGetPhysicalDeviceMemoryProperties?
    var vkGetPhysicalDeviceProperties:PFN_vkGetPhysicalDeviceProperties?
    var vkGetPhysicalDeviceQueueFamilyProperties:PFN_vkGetPhysicalDeviceQueueFamilyProperties?
    var vkGetPhysicalDeviceSparseImageFormatProperties:PFN_vkGetPhysicalDeviceSparseImageFormatProperties?
    var vkGetPhysicalDeviceSurfaceCapabilitiesKHR:PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR?
    var vkGetPhysicalDeviceSurfaceFormatsKHR:PFN_vkGetPhysicalDeviceSurfaceFormatsKHR?
    var vkGetPhysicalDeviceSurfacePresentModesKHR:PFN_vkGetPhysicalDeviceSurfacePresentModesKHR?
    var vkGetPhysicalDeviceSurfaceSupportKHR:PFN_vkGetPhysicalDeviceSurfaceSupportKHR?
    var vkGetPipelineCacheData:PFN_vkGetPipelineCacheData?
    var vkGetQueryPoolResults:PFN_vkGetQueryPoolResults?
    var vkGetRenderAreaGranularity:PFN_vkGetRenderAreaGranularity?
    var vkGetSwapchainImagesKHR:PFN_vkGetSwapchainImagesKHR?
    var vkInternalAllocationNotification:PFN_vkInternalAllocationNotification?
    var vkInternalFreeNotification:PFN_vkInternalFreeNotification?
    var vkInvalidateMappedMemoryRanges:PFN_vkInvalidateMappedMemoryRanges?
    var vkMapMemory:PFN_vkMapMemory?
    var vkMergePipelineCaches:PFN_vkMergePipelineCaches?
    var vkQueueBindSparse:PFN_vkQueueBindSparse?
    var vkQueuePresentKHR:PFN_vkQueuePresentKHR?
    var vkQueueSubmit:PFN_vkQueueSubmit?
    var vkQueueWaitIdle:PFN_vkQueueWaitIdle?
    var vkReallocationFunction:PFN_vkReallocationFunction?
    var vkResetCommandBuffer:PFN_vkResetCommandBuffer?
    var vkResetCommandPool:PFN_vkResetCommandPool?
    var vkResetDescriptorPool:PFN_vkResetDescriptorPool?
    var vkResetEvent:PFN_vkResetEvent?
    var vkResetFences:PFN_vkResetFences?
    var vkSetEvent:PFN_vkSetEvent?
    var vkUnmapMemory:PFN_vkUnmapMemory?
    var vkUpdateDescriptorSets:PFN_vkUpdateDescriptorSets?
    var vkVoidFunction:PFN_vkVoidFunction?
    var vkWaitForFences:PFN_vkWaitForFences?
    // XCB
    var vkCreateXcbSurfaceKHR:PFN_vkCreateXcbSurfaceKHR?

    init() {  
        h = dlopen("libvulkan.so",RTLD_LAZY)
        if let h = h {
            NSLog("vulkan: lunar OK")
            vkGetInstanceProcAddr = unsafeBitCast(dlsym(h, "vkGetInstanceProcAddr"), to:PFN_vkGetInstanceProcAddr.self)
            vkCreateInstance = unsafeBitCast(vkGetInstanceProcAddr!(nil,"vkCreateInstance"), to: PFN_vkCreateInstance.self)
            vkEnumerateInstanceLayerProperties = unsafeBitCast(vkGetInstanceProcAddr!(nil,"vkEnumerateInstanceLayerProperties"), to: PFN_vkEnumerateInstanceLayerProperties.self)
        } else {
            NSLog("vulkan: no lunarG, direct link")
            // XCB
            vkCreateXcbSurfaceKHR = Vulkan.vkCreateXcbSurfaceKHR
            //
            vkAcquireNextImageKHR = Vulkan.vkAcquireNextImageKHR
            vkAllocateCommandBuffers = Vulkan.vkAllocateCommandBuffers
            vkAllocateDescriptorSets = Vulkan.vkAllocateDescriptorSets
            vkAllocateMemory = Vulkan.vkAllocateMemory
            //vkAllocationFunction = Vulkan.vkAllocationFunction
            vkBeginCommandBuffer = Vulkan.vkBeginCommandBuffer
            vkBindBufferMemory = Vulkan.vkBindBufferMemory
            vkBindImageMemory = Vulkan.vkBindImageMemory
            vkCmdBeginQuery = Vulkan.vkCmdBeginQuery
            vkCmdBeginRenderPass = Vulkan.vkCmdBeginRenderPass
            vkCmdBindDescriptorSets = Vulkan.vkCmdBindDescriptorSets
            vkCmdBindIndexBuffer = Vulkan.vkCmdBindIndexBuffer
            vkCmdBindPipeline = Vulkan.vkCmdBindPipeline
            vkCmdBindVertexBuffers = Vulkan.vkCmdBindVertexBuffers
            vkCmdBlitImage = Vulkan.vkCmdBlitImage
            vkCmdClearAttachments = Vulkan.vkCmdClearAttachments
            vkCmdClearColorImage = Vulkan.vkCmdClearColorImage
            vkCmdClearDepthStencilImage = Vulkan.vkCmdClearDepthStencilImage
            vkCmdCopyBuffer = Vulkan.vkCmdCopyBuffer
            vkCmdCopyBufferToImage = Vulkan.vkCmdCopyBufferToImage
            vkCmdCopyImage = Vulkan.vkCmdCopyImage
            vkCmdCopyImageToBuffer = Vulkan.vkCmdCopyImageToBuffer
            vkCmdCopyQueryPoolResults = Vulkan.vkCmdCopyQueryPoolResults
            //vkCmdDebugMarkerBeginEXT = Vulkan.vkCmdDebugMarkerBeginEXT
            //vkCmdDebugMarkerEndEXT = Vulkan.vkCmdDebugMarkerEndEXT
            //vkCmdDebugMarkerInsertEXT = Vulkan.vkCmdDebugMarkerInsertEXT
            vkCmdDispatch = Vulkan.vkCmdDispatch
            vkCmdDispatchIndirect = Vulkan.vkCmdDispatchIndirect
            vkCmdDraw = Vulkan.vkCmdDraw
            vkCmdDrawIndexed = Vulkan.vkCmdDrawIndexed
            vkCmdDrawIndexedIndirect = Vulkan.vkCmdDrawIndexedIndirect
            vkCmdDrawIndirect = Vulkan.vkCmdDrawIndirect
            vkCmdEndQuery = Vulkan.vkCmdEndQuery
            vkCmdEndRenderPass = Vulkan.vkCmdEndRenderPass
            vkCmdExecuteCommands = Vulkan.vkCmdExecuteCommands
            vkCmdFillBuffer = Vulkan.vkCmdFillBuffer
            vkCmdNextSubpass = Vulkan.vkCmdNextSubpass
            vkCmdPipelineBarrier = Vulkan.vkCmdPipelineBarrier
            vkCmdPushConstants = Vulkan.vkCmdPushConstants
            vkCmdResetEvent = Vulkan.vkCmdResetEvent
            vkCmdResetQueryPool = Vulkan.vkCmdResetQueryPool
            vkCmdResolveImage = Vulkan.vkCmdResolveImage
            vkCmdSetBlendConstants = Vulkan.vkCmdSetBlendConstants
            vkCmdSetDepthBias = Vulkan.vkCmdSetDepthBias
            vkCmdSetDepthBounds = Vulkan.vkCmdSetDepthBounds
            vkCmdSetEvent = Vulkan.vkCmdSetEvent
            vkCmdSetLineWidth = Vulkan.vkCmdSetLineWidth
            vkCmdSetScissor = Vulkan.vkCmdSetScissor
            vkCmdSetStencilCompareMask = Vulkan.vkCmdSetStencilCompareMask
            vkCmdSetStencilReference = Vulkan.vkCmdSetStencilReference
            vkCmdSetStencilWriteMask = Vulkan.vkCmdSetStencilWriteMask
            vkCmdSetViewport = Vulkan.vkCmdSetViewport
            vkCmdUpdateBuffer = Vulkan.vkCmdUpdateBuffer
            vkCmdWaitEvents = Vulkan.vkCmdWaitEvents
            vkCmdWriteTimestamp = Vulkan.vkCmdWriteTimestamp
            vkCreateBuffer = Vulkan.vkCreateBuffer
            vkCreateBufferView = Vulkan.vkCreateBufferView
            vkCreateCommandPool = Vulkan.vkCreateCommandPool
            vkCreateComputePipelines = Vulkan.vkCreateComputePipelines
            //vkCreateDebugReportCallbackEXT = Vulkan.vkCreateDebugReportCallbackEXT
            vkCreateDescriptorPool = Vulkan.vkCreateDescriptorPool
            vkCreateDescriptorSetLayout = Vulkan.vkCreateDescriptorSetLayout
            vkCreateDevice = Vulkan.vkCreateDevice
            vkCreateDisplayModeKHR = Vulkan.vkCreateDisplayModeKHR
            vkCreateDisplayPlaneSurfaceKHR = Vulkan.vkCreateDisplayPlaneSurfaceKHR
            vkCreateEvent = Vulkan.vkCreateEvent
            vkCreateFence = Vulkan.vkCreateFence
            vkCreateFramebuffer = Vulkan.vkCreateFramebuffer
            vkCreateGraphicsPipelines = Vulkan.vkCreateGraphicsPipelines
            vkCreateImage = Vulkan.vkCreateImage
            vkCreateImageView = Vulkan.vkCreateImageView
            vkCreateInstance = Vulkan.vkCreateInstance
            vkCreatePipelineCache = Vulkan.vkCreatePipelineCache
            vkCreatePipelineLayout = Vulkan.vkCreatePipelineLayout
            vkCreateQueryPool = Vulkan.vkCreateQueryPool
            vkCreateRenderPass = Vulkan.vkCreateRenderPass
            vkCreateSampler = Vulkan.vkCreateSampler
            vkCreateSemaphore = Vulkan.vkCreateSemaphore
            vkCreateShaderModule = Vulkan.vkCreateShaderModule
            vkCreateSharedSwapchainsKHR = Vulkan.vkCreateSharedSwapchainsKHR
            vkCreateSwapchainKHR = Vulkan.vkCreateSwapchainKHR
            //vkDebugMarkerSetObjectNameEXT = Vulkan.vkDebugMarkerSetObjectNameEXT
            //vkDebugMarkerSetObjectTagEXT = Vulkan.vkDebugMarkerSetObjectTagEXT
            //vkDebugReportCallbackEXT = Vulkan.vkDebugReportCallbackEXT
            //vkDebugReportMessageEXT = Vulkan.vkDebugReportMessageEXT
            vkDestroyBuffer = Vulkan.vkDestroyBuffer
            vkDestroyBufferView = Vulkan.vkDestroyBufferView
            vkDestroyCommandPool = Vulkan.vkDestroyCommandPool
            //vkDestroyDebugReportCallbackEXT = Vulkan.vkDestroyDebugReportCallbackEXT
            vkDestroyDescriptorPool = Vulkan.vkDestroyDescriptorPool
            vkDestroyDescriptorSetLayout = Vulkan.vkDestroyDescriptorSetLayout
            vkDestroyDevice = Vulkan.vkDestroyDevice
            vkDestroyEvent = Vulkan.vkDestroyEvent
            vkDestroyFence = Vulkan.vkDestroyFence
            vkDestroyFramebuffer = Vulkan.vkDestroyFramebuffer
            vkDestroyImage = Vulkan.vkDestroyImage
            vkDestroyImageView = Vulkan.vkDestroyImageView
            vkDestroyInstance = Vulkan.vkDestroyInstance
            vkDestroyPipeline = Vulkan.vkDestroyPipeline
            vkDestroyPipelineCache = Vulkan.vkDestroyPipelineCache
            vkDestroyPipelineLayout = Vulkan.vkDestroyPipelineLayout
            vkDestroyQueryPool = Vulkan.vkDestroyQueryPool
            vkDestroyRenderPass = Vulkan.vkDestroyRenderPass
            vkDestroySampler = Vulkan.vkDestroySampler
            vkDestroySemaphore = Vulkan.vkDestroySemaphore
            vkDestroyShaderModule = Vulkan.vkDestroyShaderModule
            vkDestroySurfaceKHR = Vulkan.vkDestroySurfaceKHR
            vkDestroySwapchainKHR = Vulkan.vkDestroySwapchainKHR
            vkDeviceWaitIdle = Vulkan.vkDeviceWaitIdle
            vkEndCommandBuffer = Vulkan.vkEndCommandBuffer
            vkEnumerateDeviceExtensionProperties = Vulkan.vkEnumerateDeviceExtensionProperties
            vkEnumerateDeviceLayerProperties = Vulkan.vkEnumerateDeviceLayerProperties
            vkEnumerateInstanceExtensionProperties = Vulkan.vkEnumerateInstanceExtensionProperties
            vkEnumerateInstanceLayerProperties = Vulkan.vkEnumerateInstanceLayerProperties
            vkEnumeratePhysicalDevices = Vulkan.vkEnumeratePhysicalDevices
            vkFlushMappedMemoryRanges = Vulkan.vkFlushMappedMemoryRanges
            vkFreeCommandBuffers = Vulkan.vkFreeCommandBuffers
            vkFreeDescriptorSets = Vulkan.vkFreeDescriptorSets
            //vkFreeFunction = Vulkan.vkFreeFunction
            vkFreeMemory = Vulkan.vkFreeMemory 
            vkGetBufferMemoryRequirements = Vulkan.vkGetBufferMemoryRequirements
            vkGetDeviceMemoryCommitment = Vulkan.vkGetDeviceMemoryCommitment
            vkGetDeviceProcAddr = Vulkan.vkGetDeviceProcAddr
            vkGetDeviceQueue = Vulkan.vkGetDeviceQueue
            vkGetDisplayModePropertiesKHR = Vulkan.vkGetDisplayModePropertiesKHR
            vkGetDisplayPlaneCapabilitiesKHR = Vulkan.vkGetDisplayPlaneCapabilitiesKHR
            vkGetDisplayPlaneSupportedDisplaysKHR = Vulkan.vkGetDisplayPlaneSupportedDisplaysKHR
            vkGetEventStatus = Vulkan.vkGetEventStatus
            vkGetFenceStatus = Vulkan.vkGetFenceStatus
            vkGetImageMemoryRequirements = Vulkan.vkGetImageMemoryRequirements
            vkGetImageSparseMemoryRequirements = Vulkan.vkGetImageSparseMemoryRequirements
            vkGetImageSubresourceLayout = Vulkan.vkGetImageSubresourceLayout
            vkGetInstanceProcAddr = Vulkan.vkGetInstanceProcAddr
            vkGetPhysicalDeviceDisplayPlanePropertiesKHR = Vulkan.vkGetPhysicalDeviceDisplayPlanePropertiesKHR
            vkGetPhysicalDeviceDisplayPropertiesKHR = Vulkan.vkGetPhysicalDeviceDisplayPropertiesKHR
            vkGetPhysicalDeviceFeatures = Vulkan.vkGetPhysicalDeviceFeatures
            vkGetPhysicalDeviceFormatProperties = Vulkan.vkGetPhysicalDeviceFormatProperties
            vkGetPhysicalDeviceImageFormatProperties = Vulkan.vkGetPhysicalDeviceImageFormatProperties
            vkGetPhysicalDeviceMemoryProperties = Vulkan.vkGetPhysicalDeviceMemoryProperties
            vkGetPhysicalDeviceProperties = Vulkan.vkGetPhysicalDeviceProperties
            vkGetPhysicalDeviceQueueFamilyProperties = Vulkan.vkGetPhysicalDeviceQueueFamilyProperties
            vkGetPhysicalDeviceSparseImageFormatProperties = Vulkan.vkGetPhysicalDeviceSparseImageFormatProperties
            vkGetPhysicalDeviceSurfaceCapabilitiesKHR = Vulkan.vkGetPhysicalDeviceSurfaceCapabilitiesKHR
            vkGetPhysicalDeviceSurfaceFormatsKHR = Vulkan.vkGetPhysicalDeviceSurfaceFormatsKHR
            vkGetPhysicalDeviceSurfacePresentModesKHR = Vulkan.vkGetPhysicalDeviceSurfacePresentModesKHR
            vkGetPhysicalDeviceSurfaceSupportKHR = Vulkan.vkGetPhysicalDeviceSurfaceSupportKHR
            vkGetPipelineCacheData = Vulkan.vkGetPipelineCacheData
            vkGetQueryPoolResults = Vulkan.vkGetQueryPoolResults
            vkGetRenderAreaGranularity = Vulkan.vkGetRenderAreaGranularity
            vkGetSwapchainImagesKHR = Vulkan.vkGetSwapchainImagesKHR
            //vkInternalAllocationNotification = Vulkan.vkInternalAllocationNotification
            //vkInternalFreeNotification = Vulkan.vkInternalFreeNotification
            vkInvalidateMappedMemoryRanges = Vulkan.vkInvalidateMappedMemoryRanges
            vkMapMemory = Vulkan.vkMapMemory
            vkMergePipelineCaches = Vulkan.vkMergePipelineCaches
            vkQueueBindSparse = Vulkan.vkQueueBindSparse
            vkQueuePresentKHR = Vulkan.vkQueuePresentKHR
            vkQueueSubmit = Vulkan.vkQueueSubmit
            vkQueueWaitIdle = Vulkan.vkQueueWaitIdle
            //vkReallocationFunction = Vulkan.vkReallocationFunction
            vkResetCommandBuffer = Vulkan.vkResetCommandBuffer
            vkResetCommandPool = Vulkan.vkResetCommandPool
            vkResetDescriptorPool = Vulkan.vkResetDescriptorPool
            vkResetEvent = Vulkan.vkResetEvent
            vkResetFences = Vulkan.vkResetFences
            vkSetEvent = Vulkan.vkSetEvent
            vkUnmapMemory = Vulkan.vkUnmapMemory
            vkUpdateDescriptorSets = Vulkan.vkUpdateDescriptorSets
            //vkVoidFunction = Vulkan.vkVoidFunction
            vkWaitForFences = Vulkan.vkWaitForFences
        }
    }
    deinit {
        for c in callbacks {
            vkDestroyDebugReportCallbackEXT?(nil, c, nil)
        }
        if let h = h {
            dlclose(h)
        }
    }
    func instantiate(_ i:VkInstance) {
        if h != nil {
            // XCB
            vkCreateXcbSurfaceKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateXcbSurfaceKHR"),to:PFN_vkCreateXcbSurfaceKHR.self)
            //
            vkCreateDebugReportCallbackEXT = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateDebugReportCallbackEXT"),to:PFN_vkCreateDebugReportCallbackEXT.self)
            vkAcquireNextImageKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkAcquireNextImageKHR"),to:PFN_vkAcquireNextImageKHR.self)
            vkAllocateCommandBuffers = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkAllocateCommandBuffers"),to:PFN_vkAllocateCommandBuffers.self)
            vkAllocateDescriptorSets = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkAllocateDescriptorSets"),to:PFN_vkAllocateDescriptorSets.self)
            vkAllocateMemory = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkAllocateMemory"),to:PFN_vkAllocateMemory.self)
            vkAllocationFunction = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkAllocationFunction"),to:PFN_vkAllocationFunction.self)
            vkBeginCommandBuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkBeginCommandBuffer"),to:PFN_vkBeginCommandBuffer.self)
            vkBindBufferMemory = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkBindBufferMemory"),to:PFN_vkBindBufferMemory.self)
            vkBindImageMemory = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkBindImageMemory"),to:PFN_vkBindImageMemory.self)
            vkCmdBeginQuery = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdBeginQuery"),to:PFN_vkCmdBeginQuery.self)
            vkCmdBeginRenderPass = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdBeginRenderPass"),to:PFN_vkCmdBeginRenderPass.self)
            vkCmdBindDescriptorSets = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdBindDescriptorSets"),to:PFN_vkCmdBindDescriptorSets.self)
            vkCmdBindIndexBuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdBindIndexBuffer"),to:PFN_vkCmdBindIndexBuffer.self)
            vkCmdBindPipeline = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdBindPipeline"),to:PFN_vkCmdBindPipeline.self)
            vkCmdBindVertexBuffers = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdBindVertexBuffers"),to:PFN_vkCmdBindVertexBuffers.self)
            vkCmdBlitImage = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdBlitImage"),to:PFN_vkCmdBlitImage.self)
            vkCmdClearAttachments = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdClearAttachments"),to:PFN_vkCmdClearAttachments.self)
            vkCmdClearColorImage = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdClearColorImage"),to:PFN_vkCmdClearColorImage.self)
            vkCmdClearDepthStencilImage = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdClearDepthStencilImage"),to:PFN_vkCmdClearDepthStencilImage.self)
            vkCmdCopyBuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdCopyBuffer"),to:PFN_vkCmdCopyBuffer.self)
            vkCmdCopyBufferToImage = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdCopyBufferToImage"),to:PFN_vkCmdCopyBufferToImage.self)
            vkCmdCopyImage = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdCopyImage"),to:PFN_vkCmdCopyImage.self)
            vkCmdCopyImageToBuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdCopyImageToBuffer"),to:PFN_vkCmdCopyImageToBuffer.self)
            vkCmdCopyQueryPoolResults = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdCopyQueryPoolResults"),to:PFN_vkCmdCopyQueryPoolResults.self)
            vkCmdDebugMarkerBeginEXT = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdDebugMarkerBeginEXT"),to:PFN_vkCmdDebugMarkerBeginEXT.self)
            vkCmdDebugMarkerEndEXT = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdDebugMarkerEndEXT"),to:PFN_vkCmdDebugMarkerEndEXT.self)
            vkCmdDebugMarkerInsertEXT = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdDebugMarkerInsertEXT"),to:PFN_vkCmdDebugMarkerInsertEXT.self)
            vkCmdDispatch = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdDispatch"),to:PFN_vkCmdDispatch.self)
            vkCmdDispatchIndirect = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdDispatchIndirect"),to:PFN_vkCmdDispatchIndirect.self)
            vkCmdDraw = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdDraw"),to:PFN_vkCmdDraw.self)
            vkCmdDrawIndexed = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdDrawIndexed"),to:PFN_vkCmdDrawIndexed.self)
            vkCmdDrawIndexedIndirect = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdDrawIndexedIndirect"),to:PFN_vkCmdDrawIndexedIndirect.self)
            vkCmdDrawIndirect = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdDrawIndirect"),to:PFN_vkCmdDrawIndirect.self)
            vkCmdEndQuery = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdEndQuery"),to:PFN_vkCmdEndQuery.self)
            vkCmdEndRenderPass = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdEndRenderPass"),to:PFN_vkCmdEndRenderPass.self)
            vkCmdExecuteCommands = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdExecuteCommands"),to:PFN_vkCmdExecuteCommands.self)
            vkCmdFillBuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdFillBuffer"),to:PFN_vkCmdFillBuffer.self)
            vkCmdNextSubpass = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdNextSubpass"),to:PFN_vkCmdNextSubpass.self)
            vkCmdPipelineBarrier = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdPipelineBarrier"),to:PFN_vkCmdPipelineBarrier.self)
            vkCmdPushConstants = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdPushConstants"),to:PFN_vkCmdPushConstants.self)
            vkCmdResetEvent = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdResetEvent"),to:PFN_vkCmdResetEvent.self)
            vkCmdResetQueryPool = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdResetQueryPool"),to:PFN_vkCmdResetQueryPool.self)
            vkCmdResolveImage = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdResolveImage"),to:PFN_vkCmdResolveImage.self)
            vkCmdSetBlendConstants = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdSetBlendConstants"),to:PFN_vkCmdSetBlendConstants.self)
            vkCmdSetDepthBias = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdSetDepthBias"),to:PFN_vkCmdSetDepthBias.self)
            vkCmdSetDepthBounds = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdSetDepthBounds"),to:PFN_vkCmdSetDepthBounds.self)
            vkCmdSetEvent = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdSetEvent"),to:PFN_vkCmdSetEvent.self)
            vkCmdSetLineWidth = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdSetLineWidth"),to:PFN_vkCmdSetLineWidth.self)
            vkCmdSetScissor = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdSetScissor"),to:PFN_vkCmdSetScissor.self)
            vkCmdSetStencilCompareMask = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdSetStencilCompareMask"),to:PFN_vkCmdSetStencilCompareMask.self)
            vkCmdSetStencilReference = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdSetStencilReference"),to:PFN_vkCmdSetStencilReference.self)
            vkCmdSetStencilWriteMask = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdSetStencilWriteMask"),to:PFN_vkCmdSetStencilWriteMask.self)
            vkCmdSetViewport = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdSetViewport"),to:PFN_vkCmdSetViewport.self)
            vkCmdUpdateBuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdUpdateBuffer"),to:PFN_vkCmdUpdateBuffer.self)
            vkCmdWaitEvents = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdWaitEvents"),to:PFN_vkCmdWaitEvents.self)
            vkCmdWriteTimestamp = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCmdWriteTimestamp"),to:PFN_vkCmdWriteTimestamp.self)
            vkCreateBuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateBuffer"),to:PFN_vkCreateBuffer.self)
            vkCreateBufferView = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateBufferView"),to:PFN_vkCreateBufferView.self)
            vkCreateCommandPool = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateCommandPool"),to:PFN_vkCreateCommandPool.self)
            vkCreateComputePipelines = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateComputePipelines"),to:PFN_vkCreateComputePipelines.self)
            vkCreateDescriptorPool = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateDescriptorPool"),to:PFN_vkCreateDescriptorPool.self)
            vkCreateDescriptorSetLayout = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateDescriptorSetLayout"),to:PFN_vkCreateDescriptorSetLayout.self)
            vkCreateDevice = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateDevice"),to:PFN_vkCreateDevice.self)
            vkCreateDisplayModeKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateDisplayModeKHR"),to:PFN_vkCreateDisplayModeKHR.self)
            vkCreateDisplayPlaneSurfaceKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateDisplayPlaneSurfaceKHR"),to:PFN_vkCreateDisplayPlaneSurfaceKHR.self)
            vkCreateEvent = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateEvent"),to:PFN_vkCreateEvent.self)
            vkCreateFence = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateFence"),to:PFN_vkCreateFence.self)
            vkCreateFramebuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateFramebuffer"),to:PFN_vkCreateFramebuffer.self)
            vkCreateGraphicsPipelines = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateGraphicsPipelines"),to:PFN_vkCreateGraphicsPipelines.self)
            vkCreateImage = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateImage"),to:PFN_vkCreateImage.self)
            vkCreateImageView = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateImageView"),to:PFN_vkCreateImageView.self)
            vkCreateInstance = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateInstance"),to:PFN_vkCreateInstance.self)
            vkCreatePipelineCache = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreatePipelineCache"),to:PFN_vkCreatePipelineCache.self)
            vkCreatePipelineLayout = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreatePipelineLayout"),to:PFN_vkCreatePipelineLayout.self)
            vkCreateQueryPool = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateQueryPool"),to:PFN_vkCreateQueryPool.self)
            vkCreateRenderPass = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateRenderPass"),to:PFN_vkCreateRenderPass.self)
            vkCreateSampler = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateSampler"),to:PFN_vkCreateSampler.self)
            vkCreateSemaphore = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateSemaphore"),to:PFN_vkCreateSemaphore.self)
            vkCreateShaderModule = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateShaderModule"),to:PFN_vkCreateShaderModule.self)
            vkCreateSharedSwapchainsKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateSharedSwapchainsKHR"),to:PFN_vkCreateSharedSwapchainsKHR.self)
            vkCreateSwapchainKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkCreateSwapchainKHR"),to:PFN_vkCreateSwapchainKHR.self)
            vkDebugMarkerSetObjectNameEXT = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDebugMarkerSetObjectNameEXT"),to:PFN_vkDebugMarkerSetObjectNameEXT.self)
            vkDebugMarkerSetObjectTagEXT = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDebugMarkerSetObjectTagEXT"),to:PFN_vkDebugMarkerSetObjectTagEXT.self)
            vkDebugReportCallbackEXT = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDebugReportCallbackEXT"),to:PFN_vkDebugReportCallbackEXT.self)
            vkDebugReportMessageEXT = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDebugReportMessageEXT"),to:PFN_vkDebugReportMessageEXT.self)
            vkDestroyBuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyBuffer"),to:PFN_vkDestroyBuffer.self)
            vkDestroyBufferView = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyBufferView"),to:PFN_vkDestroyBufferView.self)
            vkDestroyCommandPool = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyCommandPool"),to:PFN_vkDestroyCommandPool.self)
            vkDestroyDebugReportCallbackEXT = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyDebugReportCallbackEXT"),to:PFN_vkDestroyDebugReportCallbackEXT.self)
            vkDestroyDescriptorPool = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyDescriptorPool"),to:PFN_vkDestroyDescriptorPool.self)
            vkDestroyDescriptorSetLayout = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyDescriptorSetLayout"),to:PFN_vkDestroyDescriptorSetLayout.self)
            vkDestroyDevice = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyDevice"),to:PFN_vkDestroyDevice.self)
            vkDestroyEvent = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyEvent"),to:PFN_vkDestroyEvent.self)
            vkDestroyFence = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyFence"),to:PFN_vkDestroyFence.self)
            vkDestroyFramebuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyFramebuffer"),to:PFN_vkDestroyFramebuffer.self)
            vkDestroyImage = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyImage"),to:PFN_vkDestroyImage.self)
            vkDestroyImageView = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyImageView"),to:PFN_vkDestroyImageView.self)
            vkDestroyInstance = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyInstance"),to:PFN_vkDestroyInstance.self)
            vkDestroyPipeline = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyPipeline"),to:PFN_vkDestroyPipeline.self)
            vkDestroyPipelineCache = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyPipelineCache"),to:PFN_vkDestroyPipelineCache.self)
            vkDestroyPipelineLayout = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyPipelineLayout"),to:PFN_vkDestroyPipelineLayout.self)
            vkDestroyQueryPool = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyQueryPool"),to:PFN_vkDestroyQueryPool.self)
            vkDestroyRenderPass = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyRenderPass"),to:PFN_vkDestroyRenderPass.self)
            vkDestroySampler = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroySampler"),to:PFN_vkDestroySampler.self)
            vkDestroySemaphore = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroySemaphore"),to:PFN_vkDestroySemaphore.self)
            vkDestroyShaderModule = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroyShaderModule"),to:PFN_vkDestroyShaderModule.self)
            vkDestroySurfaceKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroySurfaceKHR"),to:PFN_vkDestroySurfaceKHR.self)
            vkDestroySwapchainKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDestroySwapchainKHR"),to:PFN_vkDestroySwapchainKHR.self)
            vkDeviceWaitIdle = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkDeviceWaitIdle"),to:PFN_vkDeviceWaitIdle.self)
            vkEndCommandBuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkEndCommandBuffer"),to:PFN_vkEndCommandBuffer.self)
            vkEnumerateDeviceExtensionProperties = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkEnumerateDeviceExtensionProperties"),to:PFN_vkEnumerateDeviceExtensionProperties.self)
            vkEnumerateDeviceLayerProperties = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkEnumerateDeviceLayerProperties"),to:PFN_vkEnumerateDeviceLayerProperties.self)
            vkEnumerateInstanceExtensionProperties = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkEnumerateInstanceExtensionProperties"),to:PFN_vkEnumerateInstanceExtensionProperties.self)
            vkEnumeratePhysicalDevices = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkEnumeratePhysicalDevices"),to:PFN_vkEnumeratePhysicalDevices.self)
            vkFlushMappedMemoryRanges = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkFlushMappedMemoryRanges"),to:PFN_vkFlushMappedMemoryRanges.self)
            vkFreeCommandBuffers = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkFreeCommandBuffers"),to:PFN_vkFreeCommandBuffers.self)
            vkFreeDescriptorSets = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkFreeDescriptorSets"),to:PFN_vkFreeDescriptorSets.self)
            vkFreeFunction = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkFreeFunction"),to:PFN_vkFreeFunction.self)
            vkFreeMemory = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkFreeMemory"),to:PFN_vkFreeMemory.self) 
            vkGetBufferMemoryRequirements = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetBufferMemoryRequirements"),to:PFN_vkGetBufferMemoryRequirements.self)
            vkGetDeviceMemoryCommitment = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetDeviceMemoryCommitment"),to:PFN_vkGetDeviceMemoryCommitment.self)
            vkGetDeviceProcAddr = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetDeviceProcAddr"),to:PFN_vkGetDeviceProcAddr.self)
            vkGetDeviceQueue = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetDeviceQueue"),to:PFN_vkGetDeviceQueue.self)
            vkGetDisplayModePropertiesKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetDisplayModePropertiesKHR"),to:PFN_vkGetDisplayModePropertiesKHR.self)
            vkGetDisplayPlaneCapabilitiesKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetDisplayPlaneCapabilitiesKHR"),to:PFN_vkGetDisplayPlaneCapabilitiesKHR.self)
            vkGetDisplayPlaneSupportedDisplaysKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetDisplayPlaneSupportedDisplaysKHR"),to:PFN_vkGetDisplayPlaneSupportedDisplaysKHR.self)
            vkGetEventStatus = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetEventStatus"),to:PFN_vkGetEventStatus.self)
            vkGetFenceStatus = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetFenceStatus"),to:PFN_vkGetFenceStatus.self)
            vkGetImageMemoryRequirements = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetImageMemoryRequirements"),to:PFN_vkGetImageMemoryRequirements.self)
            vkGetImageSparseMemoryRequirements = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetImageSparseMemoryRequirements"),to:PFN_vkGetImageSparseMemoryRequirements.self)
            vkGetImageSubresourceLayout = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetImageSubresourceLayout"),to:PFN_vkGetImageSubresourceLayout.self)
            vkGetPhysicalDeviceDisplayPlanePropertiesKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceDisplayPlanePropertiesKHR"),to:PFN_vkGetPhysicalDeviceDisplayPlanePropertiesKHR.self)
            vkGetPhysicalDeviceDisplayPropertiesKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceDisplayPropertiesKHR"),to:PFN_vkGetPhysicalDeviceDisplayPropertiesKHR.self)
            vkGetPhysicalDeviceFeatures = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceFeatures"),to:PFN_vkGetPhysicalDeviceFeatures.self)
            vkGetPhysicalDeviceFormatProperties = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceFormatProperties"),to:PFN_vkGetPhysicalDeviceFormatProperties.self)
            vkGetPhysicalDeviceImageFormatProperties = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceImageFormatProperties"),to:PFN_vkGetPhysicalDeviceImageFormatProperties.self)
            vkGetPhysicalDeviceMemoryProperties = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceMemoryProperties"),to:PFN_vkGetPhysicalDeviceMemoryProperties.self)
            vkGetPhysicalDeviceProperties = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceProperties"),to:PFN_vkGetPhysicalDeviceProperties.self)
            vkGetPhysicalDeviceQueueFamilyProperties = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceQueueFamilyProperties"),to:PFN_vkGetPhysicalDeviceQueueFamilyProperties.self)
            vkGetPhysicalDeviceSparseImageFormatProperties = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceSparseImageFormatProperties"),to:PFN_vkGetPhysicalDeviceSparseImageFormatProperties.self)
            vkGetPhysicalDeviceSurfaceCapabilitiesKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceSurfaceCapabilitiesKHR"),to:PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR.self)
            vkGetPhysicalDeviceSurfaceFormatsKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceSurfaceFormatsKHR"),to:PFN_vkGetPhysicalDeviceSurfaceFormatsKHR.self)
            vkGetPhysicalDeviceSurfacePresentModesKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceSurfacePresentModesKHR"),to:PFN_vkGetPhysicalDeviceSurfacePresentModesKHR.self)
            vkGetPhysicalDeviceSurfaceSupportKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPhysicalDeviceSurfaceSupportKHR"),to:PFN_vkGetPhysicalDeviceSurfaceSupportKHR.self)
            vkGetPipelineCacheData = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetPipelineCacheData"),to:PFN_vkGetPipelineCacheData.self)
            vkGetQueryPoolResults = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetQueryPoolResults"),to:PFN_vkGetQueryPoolResults.self)
            vkGetRenderAreaGranularity = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetRenderAreaGranularity"),to:PFN_vkGetRenderAreaGranularity.self)
            vkGetSwapchainImagesKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkGetSwapchainImagesKHR"),to:PFN_vkGetSwapchainImagesKHR.self)
            vkInternalAllocationNotification = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkInternalAllocationNotification"),to:PFN_vkInternalAllocationNotification.self)
            vkInternalFreeNotification = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkInternalFreeNotification"),to:PFN_vkInternalFreeNotification.self)
            vkInvalidateMappedMemoryRanges = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkInvalidateMappedMemoryRanges"),to:PFN_vkInvalidateMappedMemoryRanges.self)
            vkMapMemory = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkMapMemory"),to:PFN_vkMapMemory.self)
            vkMergePipelineCaches = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkMergePipelineCaches"),to:PFN_vkMergePipelineCaches.self)
            vkQueueBindSparse = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkQueueBindSparse"),to:PFN_vkQueueBindSparse.self)
            vkQueuePresentKHR = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkQueuePresentKHR"),to:PFN_vkQueuePresentKHR.self)
            vkQueueSubmit = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkQueueSubmit"),to:PFN_vkQueueSubmit.self)
            vkQueueWaitIdle = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkQueueWaitIdle"),to:PFN_vkQueueWaitIdle.self)
            vkReallocationFunction = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkReallocationFunction"),to:PFN_vkReallocationFunction.self)
            vkResetCommandBuffer = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkResetCommandBuffer"),to:PFN_vkResetCommandBuffer.self)
            vkResetCommandPool = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkResetCommandPool"),to:PFN_vkResetCommandPool.self)
            vkResetDescriptorPool = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkResetDescriptorPool"),to:PFN_vkResetDescriptorPool.self)
            vkResetEvent = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkResetEvent"),to:PFN_vkResetEvent.self)
            vkResetFences = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkResetFences"),to:PFN_vkResetFences.self)
            vkSetEvent = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkSetEvent"),to:PFN_vkSetEvent.self)
            vkUnmapMemory = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkUnmapMemory"),to:PFN_vkUnmapMemory.self)
            vkUpdateDescriptorSets = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkUpdateDescriptorSets"),to:PFN_vkUpdateDescriptorSets.self)
            vkVoidFunction = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkVoidFunction"),to:PFN_vkVoidFunction.self)
            vkWaitForFences = unsafeBitCast(vkGetInstanceProcAddr!(i,"vkWaitForFences"),to:PFN_vkWaitForFences.self)
            initCallbacks(i)
        }
    }
    let debugReport : PFN_vkDebugReportCallbackEXT = { flags,objectType,object,location,messageCode,layerPrefix,message,userData in
        if let message = message {
            let msg = String(cString:message)
            NSLog("-------: \(msg)")
        }       
        return VkBool32(VK_FALSE)
    }
    var callbacks = [VkDebugReportCallbackEXT]()
    func initCallbacks(_ instance:VkInstance) {
        var callbackCreateInfo = VkDebugReportCallbackCreateInfoEXT()
        callbackCreateInfo.sType       = VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT
        callbackCreateInfo.pNext       = nil
        callbackCreateInfo.flags       = VK_DEBUG_REPORT_ERROR_BIT_EXT.rawValue | VK_DEBUG_REPORT_WARNING_BIT_EXT.rawValue | VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT.rawValue | VK_DEBUG_REPORT_INFORMATION_BIT_EXT.rawValue | VK_DEBUG_REPORT_DEBUG_BIT_EXT.rawValue
        callbackCreateInfo.pfnCallback = debugReport
        callbackCreateInfo.pUserData   = nil
        var cb : VkDebugReportCallbackEXT?
        if vkCreateDebugReportCallbackEXT == nil {
            NSLog("vulkan: vkCreateDebugReportCallbackEXT error")
        }
        if vkCreateDebugReportCallbackEXT!(instance, &callbackCreateInfo, nil, &cb) == VK_SUCCESS {
            callbacks.append(cb!)
            NSLog("vulkan: debug report callback OK")
        } else {
            NSLog("vulkan: debug report callback Error")
        }
    }
    public func layers() -> [(name:String,properties:VkLayerProperties)] {
        var infos = [(name:String,properties:VkLayerProperties)]()
        var layers:UInt32 = 0
        if vkEnumerateInstanceLayerProperties!(&layers,nil) == VK_SUCCESS {
            NSLog("vulkan: \(layers) layers")
            var lps = [VkLayerProperties] (repeating:VkLayerProperties(), count:Int(layers))
            if vkEnumerateInstanceLayerProperties!(&layers,&lps) == VK_SUCCESS {
                //NSLog("vulkan: layer properties OK")
                for i in 0..<Int(layers)  {
                    var lp = lps[i]
                    let count = Int(VK_MAX_EXTENSION_NAME_SIZE)
                    let ptr = UnsafeMutableRawPointer(&lp.layerName).bindMemory(to:Int8.self,capacity:count)
                    let ar = Array(UnsafeBufferPointer(start:ptr,count:count))
                    let name = String(cString:ar)
                    if name != "" {
                        //NSLog("vulkan: layer \(name)")
                        infos.append((name:name,properties:lp))
                    } else {
                        //NSLog("vulkan: layer noname")
                    }
                }
            } else {
                NSLog("vulkan: layer properties error")
            }
        }
        return infos
    }
}
