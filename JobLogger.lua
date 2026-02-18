--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local LogHandler = require('LogHandler')
local Json = require('Json')

local JobLogger = {}



function JobLogger.log(job)
	local job_type = df.job_type[job.job_type] or 'unknown'
	local job_name = dfhack.job.getName(job) or 'unknown'
	local job_unit = dfhack.job.getWorker(job)
	local job_unit_name = job_unit and dfhack.translation.translateName(job_unit.name) or 'unknown'

	local mat = dfhack.matinfo.decode(job)
	local mat_name = mat and mat:toString() or 'unknown material'

	local msg = {
		job_type = job_type,
		job_name = job_name,
		job_unit_name = job_unit_name
	}


	LogHandler.write_log("Job", msg)
end

return JobLogger
