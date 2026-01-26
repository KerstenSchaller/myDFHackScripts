local dfhack = require('dfhack')

local petitions = df.global.plotinfo.petitions

for id, petition in pairs(petitions) do
    print(string.format("Petition %d: Type=%d, Status=%d", id, petition.type, petition.status))
end