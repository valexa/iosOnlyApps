//
//  SysctlQueryHardware.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//

import Foundation

class Sysctl {
    
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
        
        private static let  kGigaBytes: size_t = 1073741824
        
        //MARK: -
        //MARK: Public - Class
        
        open class Hardware {
            
            private var m_Model: String = ""
            private var mnCPU: Double = 0
            private var mnFreq: Double = 0
            private var mnScale: Double = 0
            private var mnCores: size_t = 0
            private var mnSize: size_t = 0
            
            @discardableResult
            private class func getUsedMem(_ gigabytes: inout size_t) -> Int {
                
                var size = size_t(MemoryLayout<size_t>.stride)
                var bytes = size_t(MemoryLayout<size_t>.stride)
                
                let result = sysctlbyname("hw.usermem", &bytes, &size, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed for used memory!")
                } else {
                    gigabytes = bytes / kGigaBytes
                }
                
                return Int(result)
            }

            @discardableResult
            private class func getTotalMem(_ gigabytes: inout size_t) -> Int {

                var size = size_t(MemoryLayout<size_t>.stride)
                var bytes = size_t(MemoryLayout<size_t>.stride)

                let result = sysctlbyname("hw.memsize", &bytes, &size, nil, 0)

                if result < 0 {
                    NSLog("sysctlbyname() failed for total memory!")
                } else {
                    gigabytes = bytes / kGigaBytes
                }

                return Int(result)
            }
            
            private class func getCPUCount(_ count: inout size_t) -> Int {
                var size = size_t(MemoryLayout<size_t>.stride)
                
                let result = sysctlbyname("hw.physicalcpu_max", &count, &size, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed for max physical cpu count!")
                }
                
                return Int(result)
            }
            
            private class func getCPUClock(_ clock: inout Double) -> Int {
                var freq: size_t = 0
                var size = size_t(MemoryLayout<size_t>.stride)
                
                let result = sysctlbyname("hw.cpufrequency_max", &freq, &size, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed for max cpu frequency!")
                } else {
                    clock = Double(freq)
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
            
            public init(frequency: Double = Sysctl.Query.Frequency.kGigaHertz) {
                mnCores = 0
                mnCPU = 0.0
                mnFreq  = (frequency > 0.0) ? frequency : Sysctl.Query.Frequency.kGigaHertz
                mnScale = mnFreq
                
                var result = Sysctl.Query.Hardware.getCPUCount(&mnCores)
                
                if result >= 0 {
                    result = Sysctl.Query.Hardware.getCPUClock(&mnCPU)
                    
                    if result >= 0 {
                        mnScale *= mnFreq * mnCPU * Double(mnCores)
                    }
                }
                Sysctl.Query.Hardware.getTotalMem(&mnSize)
                Sysctl.Query.Hardware.getModel(&m_Model)
            }
            
            //CF::Query::Hardware::~Hardware()
            //{
            //    mnCores = 0;
            //    mnSize  = 0;
            //    mnFreq  = 0.0f;
            //    mnCPU   = 0.0f;
            //    mnScale = 0.0f;
            //
            //    m_Model.clear();
            //} // Destructor
            
            public init(hw: Sysctl.Query.Hardware) {
                mnCores = hw.mnCores
                mnSize = hw.mnSize
                mnCPU = hw.mnCPU
                mnFreq = hw.mnFreq
                mnScale = hw.mnScale
                m_Model = hw.m_Model
            }
            
            //CF::Query::Hardware& CF::Query::Hardware::operator=(const CF::Query::Hardware& hw)
            //{
            // 	if(this != &hw)
            //    {
            //        mnCores = hw.mnCores;
            //        mnSize  = hw.mnSize;
            //        mnCPU   = hw.mnCPU;
            //        mnFreq  = hw.mnFreq;
            //        mnScale = hw.mnScale;
            //        m_Model = hw.m_Model;
            //    } // if
            //
            //    return *this;
            //} // operator=
            
            open func setFrequency(_ frequency: Double) {
                mnFreq   = (frequency > 0.0) ? frequency : Sysctl.Query.Frequency.kGigaHertz
                mnScale  = mnFreq
                mnScale *= mnFreq * mnCPU * Double(mnCores)
            }
            
            open var cores: size_t {
                return mnCores
            }
            
            open var cpu: Double {
                return mnCPU
            }
            
            open var memory: size_t {
                return mnSize
            }
            
            open var scale: Double {
                return mnScale
            }
            
            open var model: String {
                return m_Model
            }

        }
    }
}
