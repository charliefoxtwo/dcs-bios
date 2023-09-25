local ControlType = require("ControlType")
local MockDevice = require("MockDevice")
local Module = require("Module")
local OutputType = require("OutputType")
local Suffix = require("Suffix")

local lu = require("luaunit")

--- @class TestIndicatorLight
--- @field module Module
TestIndicatorLight = {}
local moduleName = "MyModule"
local moduleAddress = 0x4200

function TestIndicatorLight:setUp()
	self.module = Module:new(moduleName, moduleAddress, {})
end

local id = "MY_LIGHT"
local arg_number = 1
local category = "Lights"
local description = "This is a light"

function TestIndicatorLight:testAddIndicatorLight()
	local control = self.module:defineIndicatorLight(id, arg_number, category, description)

	lu.assertEquals(control, self.module.documentation[category][id])
	lu.assertEquals(control.control_type, ControlType.led)
	lu.assertEquals(control.category, category)
	lu.assertEquals(control.description, description)
	lu.assertEquals(control.identifier, id)
	lu.assertIsNil(control.physical_variant)
	lu.assertIsNil(control.api_variant)

	lu.assertEquals(#control.inputs, 0)

	lu.assertEquals(#control.outputs, 1)
	local output = control.outputs[1] --[[@as IntegerOutput]]
	lu.assertEquals(output.type, OutputType.integer)
	lu.assertEquals(output.max_value, 1)
	lu.assertEquals(output.suffix, Suffix.none)
	lu.assertEquals(output.address, moduleAddress) -- first control, should be plenty of room, no need to move the address
end

function TestIndicatorLight:testIndicatorLightValue()
	self.module:defineIndicatorLight(id, arg_number, category, description)

	local export_hook = self.module.exportHooks[1]

	local alloc = self.module.memoryMap.entries[moduleAddress].allocations[1]

	export_hook(MockDevice:new(0))
	lu.assertEquals(alloc.value, 0)

	export_hook(MockDevice:new(0.29))
	lu.assertEquals(alloc.value, 0)

	export_hook(MockDevice:new(0.3))
	lu.assertEquals(alloc.value, 1)

	export_hook(MockDevice:new(1))
	lu.assertEquals(alloc.value, 1)
end
