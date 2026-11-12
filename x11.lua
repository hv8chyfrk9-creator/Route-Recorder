ese CFrame", 4, Color3.fromRGB(110, 50, 50))
local insertBtn = makeBtn(secR1, "Insertar aqui en indice", 5, Color3.fromRGB(55, 70, 100))

local secR2 = section(r, "Rellenar / suavizar", 2)
local fillFrom = makeBox(secR2, "Desde indice", 1, "1")
local fillTo = makeBox(secR2, "Hasta indice", 2, "10")
local fillStep = makeBox(secR2, "Paso studs", 3, "5")
local fillBtn = makeBtn(secR2, "Rellenar entre", 4, Color3.fromRGB(60, 90, 50))
local smoothBtn = makeBtn(secR2, "Suavizar seleccion", 5, Color3.fromRGB(70, 60, 100))

-- ==========================================
-- TAB GUARDAR / CARGAR
-- ==========================================
local s = pages.Guardar
local secS1 = section(s, "Archivo local", 1)
local saveNameBox = makeBox(secS1, "Nombre de la ruta", 1, "ruta1")
local saveBtn = makeBtn(secS1, "Guardar ruta", 2, Color3.fromRGB(40, 110, 60))
local loadBtn = makeBtn(secS1, "Cargar ruta", 3, Color3.fromRGB(40, 80, 120))
local listBtn = makeBtn(secS1, "Listar rutas guardadas", 4, Color3.fromRGB(50, 50, 70))
local delRouteBtn = makeBtn(secS1, "Borrar ruta del archivo", 5, Color3.fromRGB(110, 40, 40))

local secS2 = section(s, "Export / PlaceId", 2)
local exportBtn = makeBtn(secS2, "Exportar CFrames (clipboard)", 1, Color3.fromRGB(50, 90, 110))
local placeExportBtn = makeBtn(secS2, "Exportar con PlaceId", 2, Color3.fromRGB(50, 70, 120))

-- ==========================================
-- TAB CONFIG
-- ==========================================
local c = pages.Config
local secC1 = section(c, "WinBlocks", 1)
local winRealBox = makeBox(secC1, "Nombre real (WinBlock10)", 1, "")
local winDispBox = makeBox(secC1, "Display (+50K)", 2, "")
local winOrderBox = makeBox(secC1, "Orden", 3, "10")
local addWinBtn = makeBtn(secC1, "Anadir WinBlock", 4, Color3.fromRGB(40, 100, 55))
local clearWinsBtn = makeBtn(secC1, "Limpiar WinBlocks", 5, Color3.fromRGB(110, 50, 50))

local secC2 = section(c, "Cleanup (anti-lag)", 1)
local cleanExactBox = makeBox(secC2, "Nombre exacto a borrar", 1, "")
local cleanPrefixBox = makeBox(secC2, "Prefijo a borrar", 2, "")
local addCleanExact = makeBtn(secC2, "Anadir exacto", 3, Color3.fromRGB(40, 80, 100))
local addCleanPrefix = makeBtn(secC2, "Anadir prefijo", 4, Color3.fromRGB(40, 80, 100))
local runCleanBtn = makeBtn(secC2, "Ejecutar cleanup ahora", 5, Color3.fromRGB(90, 50, 50))
