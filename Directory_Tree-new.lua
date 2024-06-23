--[[
    DirectoryTree but i found out how to use github and found out what organization was
]]

local SETTINGS = {
    All_Instance_Abbreviation = "*all*"
}

local Root = {}
local Groups = {}

Root.__index = Root
Groups.__index = Groups

--- // Group Exports
export type Member = {
    _Personal_Connections = {} :: {RBXScriptConnection},
    __Callname
}

export type Group = {
    _Connections = {} :: {RBXScriptConnection},
    Members = {} :: {Member},
}

--- // Root Functions
function Root.new_file()
    return setmetatable({
        Groups = {},

    }, Root)
end

function Root:SetupGroup(groupName: string, memberBatch: {Instance})
    ---
    if self.Groups[groupName] then return end
    local LocalGroup = setmetatable({
        _Connections = {},
        Members = {},
    }, Groups) :: Group

    self.Groups[groupName] = LocalGroup

    for _, Member in ipairs(memberBatch) do
        ----
        LocalGroup.Members[Member] = {
            ----
            
            ----
        } :: Member
        ----
    end

    return Group
end

-- // Group Functions

function Groups:MemberSearch(memberName: string)
    for Member, _ in pairs(self.Members) do
        if Member.Name == memberName then return Member
    end
    return nil
end

function Groups:Get_Member_List()
    local r = {}

    for Member, _ in pairs(self.Members) do
        table.insert(r, Member)
    end

    return r
end

function Groups:Call_Invoke_Group(Affected: {Instance} | SETTINGS.All_Instance_Abbreviation, Invoked_Function)

    --[[
        Invoked_Function's first passed argument is the environment file in which it is running on.
        It's second argument is one of the objects in the Affected group
    ]]
    
    local abbr = SETTINGS.All_Instance_Abbreviation
    local Affected_Groups = (
        Affected ~= abbr and (typeof(Affected) == "table" and Affected or {Affected})
        or self:Get_Member_List()
    )

    for _, Member in ipairs(Affected_Groups) do

        local Match_Res = self.Members[Member]
        if not Match_Res then continue end

        Invoked_Function(self, Match_Res)
    end
    ---
end

function Groups:Link_Connections(
    Affected: {Instance} | SETTINGS.All_Instance_Abbreviation, 
    Connection_File: {
        Connection_Name: string, 
        Linked,
    })

    --[[
        "Linked" is the connected function passed by default, applied for each instance belonging to Affected.
        Remember: Reserve the first argument of "Linked" for the main Group.
    ]]
    local Connection_Name, Linked = Connection_File.Connection_Name, Connection_File.Linked
    ---
    local abbr = SETTINGS.All_Instance_Abbreviation
    local Affected_Groups = (
        Affected ~= abbr and (typeof(Affected) == "table" and Affected or {Affected})
        or self:Get_Member_List()
    )
    ---
    for _, _instance in ipairs(Affected) do
        ----
        local newConnection = _instance[Connection_Name]:Connect(Linked) :: RBXScriptConnection
        local Member_file = self.Members[_instance] :: Member

        Member_file._Personal_Connections[Connection_Name] = newConnection
        ----
    end
end

return Root