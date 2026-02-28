--add the current path to the package path so we can load other local scripts
    local dfhack = require('dfhack')
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local LogHandler = require('LogHandler')
local Json = require('Json')
local Helper = require('Helper')

local JobLogger = {}



function JobLogger.log(job)
	local job_type = df.job_type[job.job_type] or 'unknown'
	local job_name = dfhack.job.getName(job) or 'unknown'
	local job_unit = dfhack.job.getWorker(job)
	
	local mat = dfhack.matinfo.decode(job)
	local mat_name = mat and mat:toString() or 'unknown material'
	

	local parsed_job_unit = Helper.parseUnitById(job_unit.id)

	local msg = {
		job_type = job_type,
		job_name = job_name,
		job_unit = parsed_job_unit,
		material = mat_name
	}
	LogHandler.write_log("JobCompleted",msg)
end

return JobLogger
