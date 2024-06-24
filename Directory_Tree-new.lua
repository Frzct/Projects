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
    __Calls = {}:: {
        {Properties: {}, Invoked} -- these tables contain stuff
    }
}

export type Group = {
    _Connections = {} :: {RBXScriptConnection},
    Members = {} :: {Member},
}

--- // Root Functions
function Root.new_file()
    return setmetatable({
        Groups = setmetatable({}, Groups),

    }, Root)
end

function Groups:SetupGroup(groupName: string, memberBatch: {Instance})
    ---
    if not self.__Grouplist then self.__GroupList = {} end
    if self.__GroupList[groupName] then return end

    local LocalGroup = setmetatable({
        _Connections = {},
        Members = {} :: {Member},
        __GroupList = {} :: {Groups}
    }, Groups) :: Group

    self.__GroupList[groupName] = LocalGroup

    for _, Member in ipairs(memberBatch) do
        ----
        LocalGroup.Members[Member] = {
            ----
            _Personal_Connections = {} :: {RBXScriptConnection},
            __Calls = {
                "OnSendoff" = {
                    Properties = {},
                    Invoked = function(Parent_Group: Group)
                        print("Sending off "..Member.Name)
                    end
                },
                "OnReceivedOrder" = {
                    Properties = {},
                    Invoked = function(Parent_Group: Group)
                        print("Running function")
                    end
                }
            }
            ----
        } :: Member
        ----
    end

    return Groups
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

function Groups:Order_Group(Affected: {Instance} | SETTINGS.All_Instance_Abbreviation, Invoked_Function)

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

        task.spawn(function()
            ---
            local OrderCall = Match_Res.__Calls["OnReceivedOrder"]

            if OrderCall and typeof(OrderCall.Invoked) == "function" then 
                ---
                local HandledInvoke = OrderCall.Invoked
                local Properties = OrderCall.Properties
                ---
                if Properties.Run_Call_First then
                    HandledInvoke(self)
                    Invoked_Function(self, Member)
                else
                    Invoked_Function(self, Member)
                    HandledInvoke(self)
                end
            end
            ---
        end)
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
        "Linked" is the connected function passed, applying to each instance belonging to Affected.
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

function Groups:Sendoff_Member(memberList: {Instance} | SETTINGS.All_Instance_Abbreviation)
    ----
    local abbr = SETTINGS.All_Instance_Abbreviation
    local Affected_Groups = (
        Affected ~= abbr and (typeof(Affected) == "table" and Affected or {Affected})
        or self:Get_Member_List()
    )
    ----
    for _, MemberInstance in ipairs(Affected_Groups) do
        ---
        if MemberInstance.Class ~= "Instance" then continue end
        ---
        local Member_File = self.Members[MemberInstance] :: Member
        if not Member_File then continue end

        ---
        local FindCall = Member_File.__Calls["OnSendoff"]
        if FindCall and typeof(FindCall.Invoked) == "function" then FindCall.Invoked(self) end
        ---
    end
end

return Root