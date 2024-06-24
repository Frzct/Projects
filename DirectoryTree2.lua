--[[ 
	
	// DIRECTORY_TREE \\ 
	
	Is designing a fully functional UI system too difficult for you? Worry not!
	This module will (hopefully) make designing functional UI systems easier for you.
	
	Tradeoff? A lot of memory. And a bit of sanity.

    oh my god how do i use github help me
]]
local Pathway = {}
local DirTree = {}
local Group_Methods = {}

-- // Type exports \\
export type Branch = {
	__Connections: {RBXScriptConnection},
	_Instance: Instance | nil,
	__Content: {Branch}
}

export type Group_Container = {
	Groups: {Branch},
	
}
-- // Type exports end \\

local SETTINGS = {
	
}

function DirTree:GetDescendentGenerations(instance: Instance)
	
	local maxLength = 0
	
	local function subLoop(new_ins: Instance, cur_index)
		
		local thisIndex = cur_index or 0
		local children = new_ins:GetChildren()
		
		if thisIndex > maxLength then maxLength = thisIndex end
		
		for _, v in ipairs(children) do
			
			if #v:GetChildren() > 0 then
				subLoop(v, thisIndex + 1)
			end
			
		end
		
	end
	
	subLoop(instance)
	return maxLength
end
-- //  Metamethods \\
DirTree.__index = DirTree
Pathway.__index = function(_table, index)
	---
	local indexTable = string.split(index, "/")
	local cur_Index = _table :: Branch
	---
	for _, Subdirectory in ipairs(indexTable) do
		---
		if Subdirectory == "" then break end
		local ContentList = cur_Index["__Content"]
		----
		if rawget(ContentList, Subdirectory) == nil then
			
			rawset(
				ContentList, 
				Subdirectory, 
				setmetatable({
								__Connections = {},
								_Instance = nil,
								__Content = {}
							}, 
							Pathway) :: Branch
				) -- STOP STACK OVERFLOWING WHAT THE FUCK DUDE

		end
		---
		cur_Index = cur_Index["__Content"][Subdirectory]
		
	end
	---
	return cur_Index :: Branch
end
Group_Methods.__index = Group_Methods
---- // End of Metamethods \\

-- // Init methods \\
function DirTree._new(Root: Instance): {Root: Branch}
	----
	return setmetatable({
		
		Root = setmetatable({
			__Connections = {},
			_Instance = Root,
			__Content = {}
		}, Pathway) :: Branch,
		
		Groups = {
			
		}
		
	}, DirTree)
	---
end

local function getTrueLengthOfTable(_table:table)
	local length = 0
	
	for _, _ in pairs(_table) do
		length += 1
	end
	
	return length
end

--- // Dirtree Methods
function DirTree.Initialize(RootItem: any, _Description: "A better substitute for DirTree._new, where you won't have to go through each item in the list.")
	--- // I have a feeling this is not gonna be easy. \\
	
	local StartTable = DirTree._new(RootItem) -- // Sets a new RootItem to prepare for returning
	
	local function subLoop(child: Instance, SubdirString: string | nil)
		---
		local Current_Subdirectory_String = SubdirString or ""
		local SubdirCopy: string
		local Children_List = child:GetChildren()
		---
		for Index, Childer in ipairs(Children_List) do
			---
			SubdirCopy = Current_Subdirectory_String..Childer.Name.."/"
		
			StartTable:Add_Item(SubdirCopy, Childer)
			---
			if #Childer:GetChildren() > 0 then
				---- If there are children within "Childer", loop through.
				subLoop(Childer, SubdirCopy)
				----
			end
			
		end
		-- end of loop, termination inbound
		Children_List = nil
	end
	
	subLoop(RootItem)
	
	return StartTable
end
--- // Item methods
function DirTree:Add_Item(Path: string, Item: Instance)
	local Branch = self.Root[Path]
	Branch._Instance = Item
	return Branch
end
----
function DirTree:Fetch_Item(Path: string)
	return self.Root[Path]
end
---- // Recursive Loop \\

local function _RecursiveLoop(branch: Branch, topgenNumber: number, executedFunction)
	
	local function smallerRecursive(branch: Branch, genNumber: number, executedFunction)
		----

		for _, subBranch: Branch in pairs(rawget(branch, "__Content") and {branch} or branch) do
			
			executedFunction(subBranch)
			
			local isZero = true
			
			for _, _ in pairs(subBranch.__Content) do
				isZero = false
			end
			
			if not isZero and genNumber > 0 then
				smallerRecursive(subBranch.__Content, genNumber - 1, executedFunction)
			end
		end
		----
	end

	smallerRecursive(branch, topgenNumber, executedFunction)
	
end

function DirTree:AssignGroup(Group_Name: string, New_Members: {Branch})
	----
	if not self.Groups[Group_Name] then self.Groups[Group_Name] = {} end
	local Group = self.Groups[Group_Name]
	---- // Assigned groups/ Found Group
	for _, v in ipairs(New_Members) do
		table.insert(Group, v)
	end
	----
end

---- // Connection Methods \\

function DirTree:Spread_Connection(Pathway: string, ConnectionSetFunction, Generations_Affected: number) -- / PLEASE MAKE SURE GENERATIONS AFFECTED IS AN INTEGER
	
	--[[ 
		Generations_Affected: How many generations belonging to the same parent will run ConnectionSetFunction.
		ConnectionSetFunction must return 2 values: the Connection, and the Connection's name.
		ConnectionSetFunction must also have its argument be a Branch
	]]
	
	local _ConnectionRoot = self.Root[Pathway]
	
	_RecursiveLoop(_ConnectionRoot, Generations_Affected, 
		function(BranchRunning: Branch)
			---
			local Connection, Connection_Name = ConnectionSetFunction(BranchRunning)
			
			BranchRunning.__Connections[Connection_Name] = Connection
			---
		end
	)
end
----
function DirTree:Burn_Connection(Pathway: string, CrossfiredGenerations: number, Connection_Name: string)
	
	--[[
		CrossfireNumber dictates how many generations of children connections will be caught in the crossfire and killed
		Connection_Name is the connection name that should be hunted down and slaughtered brutally (ok i should refrain from heavy wording)
	]]

	local _Root = self.Root[Pathway]
	
	_RecursiveLoop(_Root, CrossfiredGenerations, function(MainBranch: Branch)
		---
		for cName, Connection: RBXScriptConnection in pairs(MainBranch.__Connections) do
			---
			if cName == Connection_Name then
				Connection:Disconnect()
				MainBranch.__Connections[cName] = nil
			end
			--
		end
		---
	end)
end
---- // DirTree Methods end

return DirTree
