//
//  SysInfo.swift
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//

import Foundation

class SysInfo {
    
    //MARK: -
    //MARK: Namespace
    
    public struct Query {
        
        //MARK: -
        //MARK: Public - Constants
        
        public struct Frequency {
            public static let kGigaHertz = 1.0e-9
            public static let kMegaHertz = 1.0e-6
            public static let kKiloHertz = 1.0e-3
            public static let kHertz = 1.0
        }
        
        
        //MARK: -
        //MARK: Private - Constants
        
        private static let  kGigaBytes = 1073741824.0
        private static let  kMegaBytes = 1048576.0
        
        //MARK: -
        //MARK: Public - Class
        
        open class Hardware {
            
            private var m_Model: String = ""
            private var mnCPU: Double = 0
            private var mnFreq: Double = 0
            private var mnScale: Double = 0
            private var mnCores: size_t = 0
            private var mnTotal: Double = 0
            private var mnUsed: Double = 0
            private var mnLoad: Int = 0
            
            @discardableResult
            private class func getUsedMem(_ gigabytes: inout Double) -> Int {
                
                var size = size_t(MemoryLayout<size_t>.stride)
                var bytes = size_t(MemoryLayout<size_t>.stride)
                
                let result = sysctlbyname("hw.usermem", &bytes, &size, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed for hw.usermem")
                } else {
                    gigabytes = Double(bytes) / kGigaBytes
                }

                return Int(result)
            }

            @discardableResult
            private class func getTotalMem(_ gigabytes: inout Double) -> Int {

                var size = size_t(MemoryLayout<size_t>.stride)
                var bytes = size_t(MemoryLayout<size_t>.stride)

                let result = sysctlbyname("hw.memsize", &bytes, &size, nil, 0)

                if result < 0 {
                    NSLog("sysctlbyname() failed for hw.memsize")
                } else {
                    gigabytes = Double(bytes) / kGigaBytes
                }

                return Int(result)
            }
            
            private class func getCPUCount(_ count: inout size_t) -> Int {
                var size = size_t(MemoryLayout<size_t>.stride)
                
                let result = sysctlbyname("hw.physicalcpu_max", &count, &size, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed for hw.physicalcpu_max")
                }
                
                return Int(result)
            }
            
            private class func getCPUClock(_ clock: inout Double) -> Int {
                var freq: size_t = 0
                var size = size_t(MemoryLayout<size_t>.stride)
                
                let result = sysctlbyname("hw.cpufrequency_max", &freq, &size, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed for hw.cpufrequency_max")
                } else {
                    clock = Double(freq)
                }
                
                return Int(result)
            }

            @discardableResult
            private class func getCPULoad(_ load: inout Int) -> Int {

                var average: loadavg = loadavg()
                var size = size_t(MemoryLayout<loadavg>.stride)

                let result = sysctlbyname("vm.loadavg", &average, &size, nil, 0)

                if result < 0 {
                    NSLog("sysctlbyname() failed for vm.loadavg")
                } else {
                    load = Int(Double(average.ldavg.0) / Double(average.fscale) * 100.0)
                }

                return Int(result)
            }
            
            @discardableResult
            private class func getModel(_ model: inout String) -> Int {
                var nLength: size_t = 0
                
                let result = sysctlbyname("hw.model", nil, &nLength, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed in acquring string length for the hardware model!")
                    
                    return Int(result)
                }
                
                if nLength != 0 {
                    var pModel: [CChar] = [CChar](repeating: 0, count: Int(nLength))
                    
                    let result = sysctlbyname("hw.model", &pModel, &nLength, nil, 0)
                    
                    if result < 0 {
                        NSLog("sysctlbyname() failed in acquring a hardware model name!")
                    } else {
                        model = String(cString: pModel)
                    }
                }
                
                return Int(result)
            }
            
            //MARK: -
            //MARK: Public - Hardware
            
            public init(frequency: Double = SysInfo.Query.Frequency.kGigaHertz) {
                mnCores = 0
                mnCPU = 0.0
                mnFreq  = (frequency > 0.0) ? frequency : SysInfo.Query.Frequency.kGigaHertz
                mnScale = mnFreq

                #if os(macOS)
                    var result = SysInfo.Query.Hardware.getCPUCount(&mnCores)
                    if result >= 0 {
                        result = SysInfo.Query.Hardware.getCPUClock(&mnCPU)

                        if result >= 0 {
                            mnScale *= mnFreq * mnCPU * Double(mnCores)
                        }
                    }
                #endif

                SysInfo.Query.Hardware.getTotalMem(&mnTotal)
                SysInfo.Query.Hardware.getUsedMem(&mnUsed)
                SysInfo.Query.Hardware.getModel(&m_Model)
                SysInfo.Query.Hardware.getCPULoad(&mnLoad)
            }

            
            public init(hw: SysInfo.Query.Hardware) {
                mnCores = hw.mnCores
                mnTotal = hw.mnTotal
                mnUsed = hw.mnUsed
                mnCPU = hw.mnCPU
                mnFreq = hw.mnFreq
                mnScale = hw.mnScale
                m_Model = hw.m_Model
                mnLoad = hw.mnLoad
            }

            open func setFrequency(_ frequency: Double) {
                mnFreq   = (frequency > 0.0) ? frequency : SysInfo.Query.Frequency.kGigaHertz
                mnScale  = mnFreq
                mnScale *= mnFreq * mnCPU * Double(mnCores)
            }
            
            open var cores: size_t {
                return mnCores
            }
            
            open var cpu: Double {
                return mnCPU
            }

            open var memoryTotal: Double {
                return mnTotal
            }

            open var memoryUsed: Double {
                return mnUsed
            }
            
            open var memoryPercent: Int {
                return Int(mnUsed / mnTotal * 100)
            }
            
            open var scale: Double {
                return mnScale
            }
            
            open var model: String {
                return m_Model
            }

            open var load: Int {
                return mnLoad
            }

        }
    }
}
