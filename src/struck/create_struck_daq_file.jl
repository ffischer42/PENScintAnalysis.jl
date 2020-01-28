
"""
        create_struck_daq_file(settings::NamedTuple)
Creates an individual `pmt_daq.scala` file
...
# Arguments
- `settings::NamedTuple`: NamedTuple containing all settings. See Example.
...
...
# Example settings
- `settings = (fadc = "gelab-fadc08", 
output_basename = "test-measurement", 
data_dir = "../data/",
conv_data_dir = "../conv_data/",
measurement_time = 20,
number_of_measurements = 5,
channels = [1,2,3,4,5,6],
trigger_threshold = 55,
trigger_pmt = 1,
peakTime = 2, 
gapTime = 2, 
nPreTrig = 192,
nSamples = 256,
saveEnergy = false
) `
...
"""

function create_struck_daq_file(settings::NamedTuple)
    new_daq = open(dirname(pathof(PENScintAnalysisTools))*"/struck/pmt_daq_6pmt_backup.scala", "r") do file
        temp = readlines(file)
        i = 1
        while i <= length(temp)
            if length(split(temp[i], "//Channels START")) > 1
                i += 1
                temp[i] = "val trig_pmt = " * string(settings.trigger_pmt)
                i += 1
                other_pmt = "val other_pmt = Ch("
                j = 1
                while j <= length(settings.channels)
                    if settings.channels[j] != settings.trigger_pmt
                        other_pmt *= string(settings.channels[j])
                        if j < length(settings.channels)
                            other_pmt *= ", "
                        end
                    end
                    j += 1
                end
                temp[i] = other_pmt*")"
                i += 1
            end

            if length(split(temp[i], "val adc = SIS3316")) > 1
                temp[i] = "val adc = SIS3316(\"vme-sis3316://"*settings.fadc*"\", \"adc\")"
            end

            if length(split(temp[i], "val outputBasename =")) > 1
                temp[i] = "val outputBasename = \""*settings.output_basename*"\""
            end

            if length(split(temp[i], "val measurementTime =")) > 1
                temp[i] = "val measurementTime = "*string(settings.measurement_time)
            end

            if length(split(temp[i], "adc.trigger_threshold_set(")) > 1
                temp[i] = "  adc.trigger_threshold_set(all_pmts --> "* string(settings.trigger_threshold) *")"
            end

            if length(split(temp[i], "val peakTime =")) > 1
                temp[i] = "val peakTime = "*string(settings.peakTime)
            end
            if length(split(temp[i], "val gapTime  =")) > 1
                temp[i] = "val gapTime =  "*string(settings.gapTime)
            end
            if length(split(temp[i], "val nPreTrig =")) > 1
                temp[i] = "val nPreTrig = "*string(settings.nPreTrig)
            end
            if length(split(temp[i], "val nSamples =")) > 1
                temp[i] = "val nSamples = "*string(settings.nSamples)
            end
            if length(split(temp[i], "save_energy =")) > 1
                temp[i] = "      save_energy = "*string(settings.saveEnergy)*","
            end


            i += 1
        end
        return(temp)
    end
    
    timestamp = string(now())
    open("pmt_daq_dont_move.scala", "w") do file
        for ln in new_daq
            write(file, ln*"\n")
        end    
    end
    #chmod("./", 0o777)
    return timestamp
end