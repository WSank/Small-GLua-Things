local include_realm = {
    sv = SERVER and include or function() end,
    cl = SERVER and AddCSLuaFile or include
}

include_realm.sh = function(f)
    AddCSLuaFile(f)
    return include(f)
end

local function Finclude(path, realm)
	local worker = include_realm[realm or "sh"]
	if worker == nil then
		realm = "sh"
		worker = include_realm.sh
	end

	if file.Find(path, "LUA") then
		if self._DEBUG then
			print(realm .." > ".. path)
		end

		return worker(path)
	end
end

local function FGetFilename(path)
    return path:match("[^/]+$")
end

local function FRemoveExtension(path)
	return path:match("(.+)%..+")
end

local function FInclude(path, realm)
	realm = realm or string.sub(self:GetFilename(path), 1, 2)
	return self:include(path, realm)
end

local function FIncludeDir(dir, recursive, realm, storage, base_path)
	base_path = base_path or dir
    local path = dir .."/"
    local files, folders = file.Find(path .."*", "LUA")

    for _, f in ipairs(files) do
    	if storage then
    		storage[self:RemoveExtension(recursive and (path:sub(#base_path + 2) .. f) or f)] = self:Include(path .. f, realm)
    	else
        	self:Include(path .. f, realm)
        end
    end

    if recursive == nil then return end

    for _, f in ipairs(folders) do
        self:IncludeDir(dir .."/".. f, recursive, realm, storage, base_path)
    end
end

local function FAddCsDir(dir, recursive)
    local path = dir .."/"
    local files, folders = file.Find(path .."*", "LUA")

    for _, f in ipairs(files) do
        AddCSLuaFile(path .. f)
    end

    if recursive == nil then return end

    for _, f in ipairs(folders) do
        self:IncludeDir(path .. f, true)
    end
end
