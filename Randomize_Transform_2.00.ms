try
(
    destroyDialog RT_LiveRandomizer
)
catch()

try
(
    if RT_RandomTransformUI != undefined and RT_RandomTransformUI.form != undefined do
        RT_RandomTransformUI.form.Close()
)
catch()

dotNet.loadAssembly "System.Windows.Forms"
dotNet.loadAssembly "System.Drawing"
try (dotNet.loadAssembly "Microsoft.VisualBasic") catch()

global RT_RandomTransformUI

struct RTData
(
    node,
    baseTM,
    randPos,
    randRot,
    randScale
)

struct RTButtonState
(
    name,
    ctrl,
    text,
    role,
    hover = false
)

struct RTToggleState
(
    name,
    ctrl,
    text,
    checked = true,
    hover = false
)

struct RTInputState
(
    name,
    panel,
    textBox,
    label,
    minValue,
    maxValue,
    defaultValue,
    isInteger = false,
    hover = false
)

struct RTLabelState
(
    ctrl,
    role
)

struct RTPreset
(
    name,
    seedValue = 12345,
    posEnabled = true,
    rotEnabled = true,
    scaleEnabled = true,
    uniformEnabled = true,
    posX = 0.0,
    posY = 0.0,
    posZ = 0.0,
    rotX = 0.0,
    rotY = 0.0,
    rotZ = 0.0,
    scaleMin = 100.0,
    scaleMax = 100.0,
    scaleXMin = 100.0,
    scaleXMax = 100.0,
    scaleYMin = 100.0,
    scaleYMax = 100.0,
    scaleZMin = 100.0,
    scaleZMax = 100.0,
    isCustom = false
)

fn RT_cardPaint sender args = (try (RT_RandomTransformUI.paintCard sender args) catch())
fn RT_buttonPaint sender args = (try (RT_RandomTransformUI.paintButton sender args) catch())
fn RT_buttonEnter sender args = (try (RT_RandomTransformUI.setButtonHover sender.Name true) catch())
fn RT_buttonLeave sender args = (try (RT_RandomTransformUI.setButtonHover sender.Name false) catch())
fn RT_buttonClick sender args = (try (RT_RandomTransformUI.handleButton sender.Name) catch())
fn RT_buttonMouseDown sender args = (try (RT_RandomTransformUI.buttonMouseDown sender.Name args) catch())
fn RT_togglePaint sender args = (try (RT_RandomTransformUI.paintToggle sender args) catch())
fn RT_toggleEnter sender args = (try (RT_RandomTransformUI.setToggleHover sender.Name true) catch())
fn RT_toggleLeave sender args = (try (RT_RandomTransformUI.setToggleHover sender.Name false) catch())
fn RT_toggleClick sender args = (try (RT_RandomTransformUI.toggleChanged sender.Name) catch())
fn RT_inputPaint sender args = (try (RT_RandomTransformUI.paintInput sender args) catch())
fn RT_inputEnter sender args = (try (RT_RandomTransformUI.setInputHover sender.Name true) catch())
fn RT_inputLeave sender args = (try (RT_RandomTransformUI.setInputHover sender.Name false) catch())
fn RT_inputTextChanged sender args = (try (RT_RandomTransformUI.inputChanged sender.Name) catch())
fn RT_inputValidated sender args = (try (RT_RandomTransformUI.normalizeInput sender.Name) catch())
fn RT_inputFocusEnter sender args = (try (RT_RandomTransformUI.setTextEditing true) catch())
fn RT_inputFocusLeave sender args = (try (RT_RandomTransformUI.setTextEditing false) catch())
fn RT_inputMouseDown sender args = (try (RT_RandomTransformUI.inputDragStart sender.Name args) catch())
fn RT_inputMouseMove sender args = (try (RT_RandomTransformUI.inputDragMove sender.Name args) catch())
fn RT_inputMouseUp sender args = (try (RT_RandomTransformUI.inputDragEnd sender.Name args) catch())
fn RT_timerTick sender args = (try (RT_RandomTransformUI.autoCaptureIfNeeded()) catch())
fn RT_formClosing sender args = (try (RT_RandomTransformUI.handleClosing()) catch())
fn RT_creditEnter sender args = (try (RT_RandomTransformUI.creditHover true) catch())
fn RT_creditLeave sender args = (try (RT_RandomTransformUI.creditHover false) catch())
fn RT_creditClick sender args = (try (shellLaunch "https://www.afoviz.com" "") catch())
fn RT_dialogButtonPaint sender args = (try (RT_RandomTransformUI.paintDialogButton sender args) catch())
fn RT_dialogButtonEnter sender args = (try (RT_RandomTransformUI.dialogButtonHover sender true) catch())
fn RT_dialogButtonLeave sender args = (try (RT_RandomTransformUI.dialogButtonHover sender false) catch())
fn RT_dialogButtonClick sender args = (try (RT_RandomTransformUI.dialogButtonClick sender args) catch())
fn RT_dialogFieldPaint sender args = (try (RT_RandomTransformUI.paintDialogField sender args) catch())
fn RT_dialogFieldEnter sender args = (try (RT_RandomTransformUI.dialogFieldHover sender true) catch())
fn RT_dialogFieldLeave sender args = (try (RT_RandomTransformUI.dialogFieldHover sender false) catch())

struct RTRandomTransformUI
(
    form,
    timer,
    items = #(),
    labels = #(),
    cards = #(),
    buttons = #(),
    toggles = #(),
    inputs = #(),
    applied = false,
    busy = false,
    closingNow = false,
    darkMode = false,
    topPinned = false,
    suppressTextEvents = false,
    editingText = false,
    previousAccelerators = true,
    dragInputName = "",
    dragStartY = 0,
    dragStartValue = 0.0,
    suppressClickName = "",
    lastSelectionSignature = "",
    creditLabel,
    presetMenu,
    presets = #(),
    currentPresetIndex = 1,
    presetDirty = false,

    backgroundLight = (dotNetClass "System.Drawing.Color").FromArgb 239 233 223,
    textLight = (dotNetClass "System.Drawing.Color").FromArgb 10 10 10,
    secondaryTextLight = (dotNetClass "System.Drawing.Color").FromArgb 80 74 68,
    borderLight = (dotNetClass "System.Drawing.Color").FromArgb 185 177 165,
    primaryButtonLight = (dotNetClass "System.Drawing.Color").FromArgb 10 10 10,
    primaryButtonTextLight = (dotNetClass "System.Drawing.Color").FromArgb 245 240 232,
    secondaryButtonLight = (dotNetClass "System.Drawing.Color").FromArgb 226 220 210,

    backgroundDark = (dotNetClass "System.Drawing.Color").FromArgb 17 16 14,
    textDark = (dotNetClass "System.Drawing.Color").FromArgb 245 240 232,
    secondaryTextDark = (dotNetClass "System.Drawing.Color").FromArgb 165 158 150,
    borderDark = (dotNetClass "System.Drawing.Color").FromArgb 52 52 52,
    primaryButtonDark = (dotNetClass "System.Drawing.Color").FromArgb 245 240 232,
    primaryButtonTextDark = (dotNetClass "System.Drawing.Color").FromArgb 17 16 14,
    secondaryButtonDark = (dotNetClass "System.Drawing.Color").FromArgb 30 30 30,

    fontTitle = dotNetObject "System.Drawing.Font" "Georgia" 24.0 (dotNetClass "System.Drawing.FontStyle").Regular,
    fontBody = dotNetObject "System.Drawing.Font" "Segoe UI" 9.0 (dotNetClass "System.Drawing.FontStyle").Regular,
    fontHeader = dotNetObject "System.Drawing.Font" "Segoe UI" 9.0 (dotNetClass "System.Drawing.FontStyle").Bold,
    fontButton = dotNetObject "System.Drawing.Font" "Segoe UI" 9.0 (dotNetClass "System.Drawing.FontStyle").Bold,
    fontIcon = dotNetObject "System.Drawing.Font" "Segoe UI Symbol" 14.0 (dotNetClass "System.Drawing.FontStyle").Regular,
    fontSpinner = dotNetObject "System.Drawing.Font" "Segoe UI Symbol" 6.0 (dotNetClass "System.Drawing.FontStyle").Regular,
    fontCredit = dotNetObject "System.Drawing.Font" "Segoe UI" 8.0 (dotNetClass "System.Drawing.FontStyle").Regular,

    fn colorBackground = if darkMode then backgroundDark else backgroundLight,
    fn colorText = if darkMode then textDark else textLight,
    fn colorSecondaryText = if darkMode then secondaryTextDark else secondaryTextLight,
    fn colorBorder = if darkMode then borderDark else borderLight,
    fn colorPrimaryButton = if darkMode then primaryButtonDark else primaryButtonLight,
    fn colorPrimaryButtonText = if darkMode then primaryButtonTextDark else primaryButtonTextLight,
    fn colorSecondaryButton = if darkMode then secondaryButtonDark else secondaryButtonLight,

    fn iconFromCode code = ((dotNetClass "System.Char").ConvertFromUtf32 code),
    fn iconMoon = iconFromCode 9790,
    fn iconSun = iconFromCode 9728,
    fn iconPin = iconFromCode 128204,

    fn brighten color amount =
    (
        local colorClass = dotNetClass "System.Drawing.Color"
        local r = color.R + (((255 - color.R) * amount) as integer)
        local g = color.G + (((255 - color.G) * amount) as integer)
        local b = color.B + (((255 - color.B) * amount) as integer)
        colorClass.FromArgb r g b
    ),

    fn darken color amount =
    (
        local colorClass = dotNetClass "System.Drawing.Color"
        local r = color.R - ((color.R * amount) as integer)
        local g = color.G - ((color.G * amount) as integer)
        local b = color.B - ((color.B * amount) as integer)
        if r < 0 do r = 0
        if g < 0 do g = 0
        if b < 0 do b = 0
        colorClass.FromArgb r g b
    ),

    fn hoverAmount = if darkMode then 0.08 else 0.06,

    fn roundedPath x y w h r =
    (
        local path = dotNetObject "System.Drawing.Drawing2D.GraphicsPath"
        local d = r * 2
        path.AddArc (dotNetObject "System.Drawing.Rectangle" x y d d) 180.0 90.0
        path.AddArc (dotNetObject "System.Drawing.Rectangle" (x + w - d) y d d) 270.0 90.0
        path.AddArc (dotNetObject "System.Drawing.Rectangle" (x + w - d) (y + h - d) d d) 0.0 90.0
        path.AddArc (dotNetObject "System.Drawing.Rectangle" x (y + h - d) d d) 90.0 90.0
        path.CloseFigure()
        path
    ),

    fn paintRoundedBox g x y w h r fillColor borderColor =
    (
        local path = roundedPath x y w h r
        local brush = dotNetObject "System.Drawing.SolidBrush" fillColor
        local pen = dotNetObject "System.Drawing.Pen" borderColor 1.0
        g.FillPath brush path
        g.DrawPath pen path
        brush.Dispose()
        pen.Dispose()
        path.Dispose()
    ),

    fn drawTextCentered g text font color rect =
    (
        local brush = dotNetObject "System.Drawing.SolidBrush" color
        local format = dotNetObject "System.Drawing.StringFormat"
        format.Alignment = (dotNetClass "System.Drawing.StringAlignment").Center
        format.LineAlignment = (dotNetClass "System.Drawing.StringAlignment").Center
        g.DrawString text font brush rect format
        brush.Dispose()
        format.Dispose()
    ),

    fn labelRoleColor role =
    (
        case role of
        (
            #primary: colorText()
            #secondary: colorSecondaryText()
            #header: colorText()
            #credit: colorSecondaryText()
            default: colorText()
        )
    ),

    fn setControlBounds ctrl x y w h =
    (
        ctrl.SetBounds x y w h
        ctrl
    ),

    fn createLabel text x y w h role font =
    (
        local lbl = dotNetObject "System.Windows.Forms.Label"
        lbl.Text = text
        lbl.AutoSize = false
        lbl.BackColor = colorBackground()
        lbl.ForeColor = labelRoleColor role
        lbl.Font = font
        lbl.TextAlign = (dotNetClass "System.Drawing.ContentAlignment").MiddleLeft
        setControlBounds lbl x y w h
        form.Controls.Add lbl
        lbl.BringToFront()
        append labels (RTLabelState ctrl:lbl role:role)
        lbl
    ),

    fn createCard name x y w h =
    (
        local panel = dotNetObject "System.Windows.Forms.Panel"
        panel.Name = name
        panel.BackColor = colorBackground()
        setControlBounds panel x y w h
        dotNet.addEventHandler panel "Paint" RT_cardPaint
        form.Controls.Add panel
        panel.SendToBack()
        append cards panel
        panel
    ),

    fn createButton name text x y w h role =
    (
        local panel = dotNetObject "System.Windows.Forms.Panel"
        panel.Name = name
        panel.BackColor = colorBackground()
        panel.Cursor = (dotNetClass "System.Windows.Forms.Cursors").Hand
        setControlBounds panel x y w h
        dotNet.addEventHandler panel "Paint" RT_buttonPaint
        dotNet.addEventHandler panel "MouseEnter" RT_buttonEnter
        dotNet.addEventHandler panel "MouseLeave" RT_buttonLeave
        dotNet.addEventHandler panel "MouseDown" RT_buttonMouseDown
        dotNet.addEventHandler panel "Click" RT_buttonClick
        form.Controls.Add panel
        panel.BringToFront()
        append buttons (RTButtonState name:name ctrl:panel text:text role:role)
        panel
    ),

    fn createToggle name text x y checked =
    (
        local panel = dotNetObject "System.Windows.Forms.Panel"
        panel.Name = name
        panel.BackColor = colorBackground()
        panel.Cursor = (dotNetClass "System.Windows.Forms.Cursors").Hand
        local toggleWidth = case name of
        (
            "scaleEnable": 108
            default: 180
        )
        setControlBounds panel x y toggleWidth 28
        dotNet.addEventHandler panel "Paint" RT_togglePaint
        dotNet.addEventHandler panel "MouseEnter" RT_toggleEnter
        dotNet.addEventHandler panel "MouseLeave" RT_toggleLeave
        dotNet.addEventHandler panel "Click" RT_toggleClick
        form.Controls.Add panel
        panel.BringToFront()
        append toggles (RTToggleState name:name ctrl:panel text:text checked:checked)
        panel
    ),

    fn createInput name labelText x y w defaultValue minValue maxValue isInteger =
    (
        local lbl = undefined
        if labelText != "" do
            lbl = createLabel labelText x (y - 21) w 18 #secondary fontBody
        local panel = dotNetObject "System.Windows.Forms.Panel"
        local tb = dotNetObject "System.Windows.Forms.TextBox"

        panel.Name = name
        panel.BackColor = colorBackground()
        panel.Cursor = (dotNetClass "System.Windows.Forms.Cursors").SizeNS
        setControlBounds panel x y w 34
        dotNet.addEventHandler panel "Paint" RT_inputPaint
        dotNet.addEventHandler panel "MouseEnter" RT_inputEnter
        dotNet.addEventHandler panel "MouseLeave" RT_inputLeave
        dotNet.addEventHandler panel "MouseDown" RT_inputMouseDown
        dotNet.addEventHandler panel "MouseMove" RT_inputMouseMove
        dotNet.addEventHandler panel "MouseUp" RT_inputMouseUp

        tb.Name = name
        tb.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").None
        tb.BackColor = colorSecondaryButton()
        tb.ForeColor = colorText()
        tb.Font = fontBody
        tb.Cursor = (dotNetClass "System.Windows.Forms.Cursors").IBeam
        tb.TextAlign = (dotNetClass "System.Windows.Forms.HorizontalAlignment").Right
        tb.Text = if isInteger then ((defaultValue as integer) as string) else (defaultValue as string)
        setControlBounds tb 10 8 (w - 44) 18
        dotNet.addEventHandler tb "MouseEnter" RT_inputEnter
        dotNet.addEventHandler tb "MouseLeave" RT_inputLeave
        dotNet.addEventHandler tb "Enter" RT_inputFocusEnter
        dotNet.addEventHandler tb "TextChanged" RT_inputTextChanged
        dotNet.addEventHandler tb "Leave" RT_inputFocusLeave
        dotNet.addEventHandler tb "Leave" RT_inputValidated

        panel.Controls.Add tb
        form.Controls.Add panel
        panel.BringToFront()

        append inputs (RTInputState name:name panel:panel textBox:tb label:lbl minValue:minValue maxValue:maxValue defaultValue:defaultValue isInteger:isInteger)
        panel
    ),

    fn buttonIndex name =
    (
        for i = 1 to buttons.count where buttons[i].name == name do return i
        0
    ),

    fn cardIndex name =
    (
        for i = 1 to cards.count where cards[i].Name == name do return i
        0
    ),

    fn setButtonBounds name x y w h =
    (
        local idx = buttonIndex name
        if idx > 0 do buttons[idx].ctrl.SetBounds x y w h
    ),

    fn setCardBounds name x y w h =
    (
        local idx = cardIndex name
        if idx > 0 do
        (
            cards[idx].SetBounds x y w h
            cards[idx].Invalidate()
        )
    ),

    fn toggleIndex name =
    (
        for i = 1 to toggles.count where toggles[i].name == name do return i
        0
    ),

    fn inputIndex name =
    (
        for i = 1 to inputs.count where inputs[i].name == name do return i
        0
    ),

    fn setButtonText name text =
    (
        local idx = buttonIndex name
        if idx > 0 do
        (
            buttons[idx].text = text
            buttons[idx].ctrl.Invalidate()
        )
    ),

    fn setButtonHover name value =
    (
        local idx = buttonIndex name
        if idx > 0 do
        (
            buttons[idx].hover = value
            buttons[idx].ctrl.Invalidate()
        )
    ),

    fn setToggleHover name value =
    (
        local idx = toggleIndex name
        if idx > 0 do
        (
            toggles[idx].hover = value
            toggles[idx].ctrl.Invalidate()
        )
    ),

    fn setInputHover name value =
    (
        local idx = inputIndex name
        if idx > 0 do
        (
            inputs[idx].hover = value
            local fill = if value then brighten (colorSecondaryButton()) (hoverAmount()) else colorSecondaryButton()
            inputs[idx].textBox.BackColor = fill
            inputs[idx].panel.Invalidate()
        )
    ),

    fn setTextEditing value =
    (
        if value then
        (
            if not editingText do
            (
                editingText = true
                try (previousAccelerators = enableAccelerators) catch (previousAccelerators = true)
                try (enableAccelerators = false) catch()
            )
        )
        else
        (
            if editingText do
            (
                editingText = false
                try (enableAccelerators = previousAccelerators) catch()
            )
        )
    ),

    fn paintCard sender args =
    (
        args.Graphics.SmoothingMode = (dotNetClass "System.Drawing.Drawing2D.SmoothingMode").AntiAlias
        paintRoundedBox args.Graphics 0 0 (sender.Width - 1) (sender.Height - 1) 12 (colorBackground()) (colorBorder())
    ),

    fn paintButton sender args =
    (
        local idx = buttonIndex sender.Name
        if idx == 0 do return false

        local b = buttons[idx]
        local fill = if b.role == #primary then colorPrimaryButton() else colorSecondaryButton()
        local textColor = if b.role == #primary then colorPrimaryButtonText() else colorText()
        if b.hover do fill = brighten fill (hoverAmount())

        args.Graphics.SmoothingMode = (dotNetClass "System.Drawing.Drawing2D.SmoothingMode").AntiAlias

        if matchPattern b.name pattern:"presetItem_*" do
        (
            local indexText = substring b.name 12 (b.name.count - 11)
            local itemIndex = indexText as integer
            local selected = (not presetDirty) and itemIndex == currentPresetIndex

            if b.hover or selected do
            (
                local rowFill = if selected then brighten (colorSecondaryButton()) 0.03 else brighten (colorSecondaryButton()) (hoverAmount())
                paintRoundedBox args.Graphics 2 3 (sender.Width - 4) (sender.Height - 6) 6 rowFill rowFill
            )

            local brush = dotNetObject "System.Drawing.SolidBrush" (colorText())
            local format = dotNetObject "System.Drawing.StringFormat"
            format.Alignment = (dotNetClass "System.Drawing.StringAlignment").Near
            format.LineAlignment = (dotNetClass "System.Drawing.StringAlignment").Center
            local textRect = dotNetObject "System.Drawing.RectangleF" 10.0 0.0 ((sender.Width - 20) as float) (sender.Height as float)
            args.Graphics.DrawString b.text fontBody brush textRect format
            brush.Dispose()
            format.Dispose()
            return true
        )

        if b.name == "pin" or b.name == "theme" do
        (
            local selected = (b.name == "pin" and topPinned) or (b.name == "theme" and darkMode)
            fill = if selected then colorPrimaryButton() else colorSecondaryButton()
            textColor = if selected then colorPrimaryButtonText() else colorText()
            if b.hover do textColor = if darkMode then brighten textColor 0.18 else darken textColor 0.22

            paintRoundedBox args.Graphics 0 0 (sender.Width - 1) (sender.Height - 1) 10 fill (colorBorder())
            local iconRect = dotNetObject "System.Drawing.RectangleF" 0.0 0.0 (sender.Width as float) (sender.Height as float)
            drawTextCentered args.Graphics b.text fontIcon textColor iconRect
            return true
        )

        paintRoundedBox args.Graphics 0 0 (sender.Width - 1) (sender.Height - 1) 10 fill (colorBorder())

        local rect = dotNetObject "System.Drawing.RectangleF" 0.0 0.0 (sender.Width as float) (sender.Height as float)
        local drawFont = if (b.name == "pin" or b.name == "theme") then fontIcon else fontButton

        if b.name == "presetDrop" then
        (
            local brush = dotNetObject "System.Drawing.SolidBrush" textColor
            local format = dotNetObject "System.Drawing.StringFormat"
            format.Alignment = (dotNetClass "System.Drawing.StringAlignment").Near
            format.LineAlignment = (dotNetClass "System.Drawing.StringAlignment").Center
            local textRect = dotNetObject "System.Drawing.RectangleF" 16.0 0.0 ((sender.Width - 52) as float) (sender.Height as float)
            local arrowRect = dotNetObject "System.Drawing.RectangleF" ((sender.Width - 36) as float) 0.0 24.0 (sender.Height as float)
            args.Graphics.DrawString b.text fontButton brush textRect format
            drawTextCentered args.Graphics (iconFromCode 9662) fontBody textColor arrowRect
            brush.Dispose()
            format.Dispose()
        )
        else
        (
            drawTextCentered args.Graphics b.text drawFont textColor rect
        )
    ),

    fn paintToggle sender args =
    (
        local idx = toggleIndex sender.Name
        if idx == 0 do return false

        local t = toggles[idx]
        local checkFill = if t.checked then colorPrimaryButton() else colorSecondaryButton()
        if t.hover do checkFill = brighten checkFill (hoverAmount())

        args.Graphics.SmoothingMode = (dotNetClass "System.Drawing.Drawing2D.SmoothingMode").AntiAlias
        paintRoundedBox args.Graphics 0 4 20 20 6 checkFill (colorBorder())

        if t.checked do
        (
            local pen = dotNetObject "System.Drawing.Pen" (colorPrimaryButtonText()) 2.0
            args.Graphics.DrawLine pen 5 14 9 18
            args.Graphics.DrawLine pen 9 18 16 9
            pen.Dispose()
        )

        local brush = dotNetObject "System.Drawing.SolidBrush" (colorText())
        local format = dotNetObject "System.Drawing.StringFormat"
        format.LineAlignment = (dotNetClass "System.Drawing.StringAlignment").Center
        local rect = dotNetObject "System.Drawing.RectangleF" 30.0 0.0 ((sender.Width - 30) as float) (sender.Height as float)
        args.Graphics.DrawString t.text fontBody brush rect format
        brush.Dispose()
        format.Dispose()
    ),

    fn paintInput sender args =
    (
        local idx = inputIndex sender.Name
        if idx == 0 do return false

        local fill = if inputs[idx].hover then brighten (colorSecondaryButton()) (hoverAmount()) else colorSecondaryButton()
        local handleColor = if inputs[idx].hover then colorText() else colorSecondaryText()
        args.Graphics.SmoothingMode = (dotNetClass "System.Drawing.Drawing2D.SmoothingMode").AntiAlias
        paintRoundedBox args.Graphics 0 0 (sender.Width - 1) (sender.Height - 1) 10 fill (colorBorder())

        local pen = dotNetObject "System.Drawing.Pen" (colorBorder()) 1.0
        args.Graphics.DrawLine pen (sender.Width - 30) 8 (sender.Width - 30) (sender.Height - 8)
        pen.Dispose()

        local brush = dotNetObject "System.Drawing.SolidBrush" handleColor
        args.Graphics.DrawString (iconFromCode 9650) fontSpinner brush ((sender.Width - 22) as float) 5.0
        args.Graphics.DrawString (iconFromCode 9660) fontSpinner brush ((sender.Width - 22) as float) 17.0
        brush.Dispose()
    ),

    fn paintDialogField sender args =
    (
        local fill = if sender.AccessibleName == "hover" then brighten (colorSecondaryButton()) (hoverAmount()) else colorSecondaryButton()
        args.Graphics.SmoothingMode = (dotNetClass "System.Drawing.Drawing2D.SmoothingMode").AntiAlias
        paintRoundedBox args.Graphics 0 0 (sender.Width - 1) (sender.Height - 1) 10 fill (colorBorder())
    ),

    fn dialogFieldHover sender hovering =
    (
        local target = sender
        try (if sender.Parent != undefined and sender.Parent.Name == "presetNameField" do target = sender.Parent) catch()
        target.AccessibleName = if hovering then "hover" else ""
        target.Invalidate()
    ),

    fn paintDialogButton sender args =
    (
        local isPrimary = (sender.Tag as string) == "primary"
        local fill = if isPrimary then colorPrimaryButton() else colorSecondaryButton()
        local textColor = if isPrimary then colorPrimaryButtonText() else colorText()
        if sender.AccessibleName == "hover" do fill = brighten fill (hoverAmount())

        args.Graphics.SmoothingMode = (dotNetClass "System.Drawing.Drawing2D.SmoothingMode").AntiAlias
        paintRoundedBox args.Graphics 0 0 (sender.Width - 1) (sender.Height - 1) 10 fill (colorBorder())

        local rect = dotNetObject "System.Drawing.RectangleF" 0.0 0.0 (sender.Width as float) (sender.Height as float)
        drawTextCentered args.Graphics sender.Text fontButton textColor rect
    ),

    fn dialogButtonHover sender hovering =
    (
        sender.AccessibleName = if hovering then "hover" else ""
        sender.Invalidate()
    ),

    fn dialogButtonClick sender args =
    (
        local dialog = sender.FindForm()
        if dialog == undefined do return false

        local resultClass = dotNetClass "System.Windows.Forms.DialogResult"
        dialog.DialogResult = if sender.AccessibleDescription == "OK" then resultClass.OK else resultClass.Cancel
        dialog.Close()
    ),

    fn inputStep name =
    (
        case name of
        (
            "seed": 1.0
            "rotX": 0.5
            "rotY": 0.5
            "rotZ": 0.5
            "scaleMin": 1.0
            "scaleMax": 1.0
            default: 0.1
        )
    ),

    fn creditHover hovering =
    (
        if creditLabel != undefined do
        (
            local c = if hovering then colorText() else colorSecondaryText()
            creditLabel.ForeColor = c
            creditLabel.LinkColor = c
            creditLabel.ActiveLinkColor = c
            creditLabel.VisitedLinkColor = c
        )
    ),

    fn applyTheme =
    (
        local bg = colorBackground()
        local txt = colorText()
        local fieldFill = colorSecondaryButton()

        if form != undefined do form.BackColor = bg

        for card in cards do
        (
            card.BackColor = bg
            card.Invalidate()
        )

        for lblState in labels do
        (
            lblState.ctrl.BackColor = bg
            lblState.ctrl.ForeColor = labelRoleColor lblState.role
        )

        for b in buttons do
        (
            b.ctrl.BackColor = bg
            b.ctrl.Invalidate()
        )

        for t in toggles do
        (
            t.ctrl.BackColor = bg
            t.ctrl.Invalidate()
        )

        for input in inputs do
        (
            input.panel.BackColor = bg
            input.textBox.BackColor = fieldFill
            input.textBox.ForeColor = txt
            input.panel.Invalidate()
        )

        if presetMenu != undefined do
        (
            presetMenu.BackColor = bg
            presetMenu.Invalidate()
        )

        if creditLabel != undefined do
        (
            creditLabel.ForeColor = colorSecondaryText()
            creditLabel.LinkColor = colorSecondaryText()
            creditLabel.ActiveLinkColor = colorText()
            creditLabel.VisitedLinkColor = colorSecondaryText()
        )
        setButtonText "theme" (if darkMode then iconSun() else iconMoon())
        setButtonText "pin" (iconPin())
    ),

    fn getToggleValue name defaultValue =
    (
        local idx = toggleIndex name
        if idx > 0 then toggles[idx].checked else defaultValue
    ),

    fn setToggleValue name value =
    (
        local idx = toggleIndex name
        if idx > 0 do
        (
            toggles[idx].checked = value
            toggles[idx].ctrl.Invalidate()
        )
    ),

    fn getInputValue name =
    (
        local idx = inputIndex name
        if idx == 0 do return 0

        local input = inputs[idx]
        local v = input.defaultValue
        try (v = input.textBox.Text as float) catch (v = input.defaultValue)
        if v == undefined do v = input.defaultValue
        if v < input.minValue do v = input.minValue
        if v > input.maxValue do v = input.maxValue
        if input.isInteger then (v as integer) else v
    ),

    fn setInputValue name value refresh =
    (
        local idx = inputIndex name
        if idx == 0 do return false

        local input = inputs[idx]
        local v = value
        if v < input.minValue do v = input.minValue
        if v > input.maxValue do v = input.maxValue
        if input.isInteger do v = v as integer

        suppressTextEvents = true
        input.textBox.Text = if input.isInteger then ((v as integer) as string) else (v as string)
        suppressTextEvents = false

        if refresh do RT_RandomTransformUI.inputChanged name
    ),

    fn setInputVisible name visible =
    (
        local idx = inputIndex name
        if idx > 0 do
        (
            inputs[idx].panel.Visible = visible
            if inputs[idx].label != undefined do inputs[idx].label.Visible = visible
        )
    ),

    fn setWindowHeights clientH outerH =
    (
        if form != undefined do
        (
            if outerH < form.MinimumSize.Height then
            (
                form.MinimumSize = dotNetObject "System.Drawing.Size" 656 outerH
                form.MaximumSize = dotNetObject "System.Drawing.Size" 656 outerH
            )
            else
            (
                form.MaximumSize = dotNetObject "System.Drawing.Size" 656 outerH
                form.MinimumSize = dotNetObject "System.Drawing.Size" 656 outerH
            )
            form.ClientSize = dotNetObject "System.Drawing.Size" 640 clientH
        )
    ),

    fn updateScaleLayout =
    (
        local uniformEnabled = getToggleValue "uniformScale" true

        if uniformEnabled then
        (
            setCardBounds "scaleCard" 24 410 592 154
            setButtonBounds "apply" 24 586 286 38
            setButtonBounds "revert" 330 586 286 38
            if creditLabel != undefined do creditLabel.SetBounds 24 638 592 22
            setWindowHeights 684 723
        )
        else
        (
            setCardBounds "scaleCard" 24 410 592 222
            setButtonBounds "apply" 24 652 286 38
            setButtonBounds "revert" 330 652 286 38
            if creditLabel != undefined do creditLabel.SetBounds 24 706 592 22
            setWindowHeights 752 791
        )
    ),

    fn updateScaleInputVisibility =
    (
        local uniformEnabled = getToggleValue "uniformScale" true

        setInputVisible "scaleMin" uniformEnabled
        setInputVisible "scaleMax" uniformEnabled

        setInputVisible "scaleXMin" (not uniformEnabled)
        setInputVisible "scaleXMax" (not uniformEnabled)
        setInputVisible "scaleYMin" (not uniformEnabled)
        setInputVisible "scaleYMax" (not uniformEnabled)
        setInputVisible "scaleZMin" (not uniformEnabled)
        setInputVisible "scaleZMax" (not uniformEnabled)
        updateScaleLayout()
    ),

    fn enforceInputPair minName maxName changedName =
    (
        local minValue = getInputValue minName
        local maxValue = getInputValue maxName

        if minValue > maxValue do
        (
            if changedName == maxName then
                setInputValue maxName minValue false
            else
                setInputValue minName maxValue false
        )
    ),

    fn enforceScaleRanges changedName =
    (
        enforceInputPair "scaleMin" "scaleMax" changedName
        enforceInputPair "scaleXMin" "scaleXMax" changedName
        enforceInputPair "scaleYMin" "scaleYMax" changedName
        enforceInputPair "scaleZMin" "scaleZMax" changedName
    ),

    fn normalizeInput name =
    (
        if suppressTextEvents do return false
        local idx = inputIndex name
        if idx == 0 do return false

        local v = getInputValue name
        suppressTextEvents = true
        inputs[idx].textBox.Text = if inputs[idx].isInteger then ((v as integer) as string) else (v as string)
        suppressTextEvents = false
        RT_RandomTransformUI.inputChanged name
    ),

    fn inputDragStart name args =
    (
        local idx = inputIndex name
        if idx == 0 do return false
        if args.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Right do
        (
            if args.X < (inputs[idx].panel.Width - 30) do return false
            setInputValue name inputs[idx].defaultValue true
            return false
        )
        if args.Button != (dotNetClass "System.Windows.Forms.MouseButtons").Left do return false
        if args.X < (inputs[idx].panel.Width - 30) do return false

        dragInputName = name
        dragStartY = args.Y
        dragStartValue = getInputValue name
        inputs[idx].panel.Capture = true

        local step = inputStep name
        if args.Y < (inputs[idx].panel.Height / 2) then
            setInputValue name (dragStartValue + step) true
        else
            setInputValue name (dragStartValue - step) true

        dragStartValue = getInputValue name
    ),

    fn inputDragMove name args =
    (
        if dragInputName != name do return false

        local delta = dragStartY - args.Y
        if delta != 0 do
            setInputValue name (dragStartValue + (delta * (inputStep name))) true
    ),

    fn inputDragEnd name args =
    (
        if dragInputName == name do
        (
            local idx = inputIndex name
            if idx > 0 do inputs[idx].panel.Capture = false
            dragInputName = ""
            normalizeInput name
        )
    ),

    fn presetStoragePath =
    (
        local dir = ""
        try (dir = pathConfig.getDir #userScripts) catch()
        if dir == undefined or dir == "" do
            try (dir = getDir #scripts) catch()
        if dir == undefined or dir == "" do
            dir = getFilenamePath (getSourceFileName())

        dir + "\\Randomize_Transform_Presets.txt"
    ),

    fn cleanPresetName name =
    (
        local n = substituteString name "|" "-"
        n = substituteString n "\n" " "
        n = substituteString n "\r" " "
        n
    ),

    fn boolText value = if value then "1" else "0",
    fn boolFromText value = value == "1" or value == "true" or value == "True",

    fn stockPresets =
    (
        #(
            RTPreset name:"Default settings" seedValue:12345 posX:0 posY:0 posZ:0 rotX:0 rotY:0 rotZ:0 scaleMin:100 scaleMax:100 scaleXMin:100 scaleXMax:100 scaleYMin:100 scaleYMax:100 scaleZMin:100 scaleZMax:100,
            RTPreset name:"Subtle Position" seedValue:12345 posX:10 posY:10 posZ:0 rotX:0 rotY:0 rotZ:0 scaleMin:100 scaleMax:100 scaleXMin:100 scaleXMax:100 scaleYMin:100 scaleYMax:100 scaleZMin:100 scaleZMax:100,
            RTPreset name:"Rotation Variation" seedValue:12345 posX:0 posY:0 posZ:0 rotX:15 rotY:15 rotZ:45 scaleMin:100 scaleMax:100 scaleXMin:100 scaleXMax:100 scaleYMin:100 scaleYMax:100 scaleZMin:100 scaleZMax:100,
            RTPreset name:"Scale Variation" seedValue:12345 posX:0 posY:0 posZ:0 rotX:0 rotY:0 rotZ:0 scaleMin:85 scaleMax:115 scaleXMin:85 scaleXMax:115 scaleYMin:85 scaleYMax:115 scaleZMin:85 scaleZMax:115,
            RTPreset name:"Full Variation" seedValue:12345 posX:10 posY:10 posZ:5 rotX:10 rotY:10 rotZ:20 scaleMin:90 scaleMax:110 scaleXMin:90 scaleXMax:110 scaleYMin:90 scaleYMax:110 scaleZMin:90 scaleZMax:110
        )
    ),

    fn presetToLine preset =
    (
        (cleanPresetName preset.name) + "|" + \
        (preset.seedValue as string) + "|" + \
        (boolText preset.posEnabled) + "|" + \
        (boolText preset.rotEnabled) + "|" + \
        (boolText preset.scaleEnabled) + "|" + \
        (boolText preset.uniformEnabled) + "|" + \
        (preset.posX as string) + "|" + \
        (preset.posY as string) + "|" + \
        (preset.posZ as string) + "|" + \
        (preset.rotX as string) + "|" + \
        (preset.rotY as string) + "|" + \
        (preset.rotZ as string) + "|" + \
        (preset.scaleMin as string) + "|" + \
        (preset.scaleMax as string) + "|" + \
        (preset.scaleXMin as string) + "|" + \
        (preset.scaleXMax as string) + "|" + \
        (preset.scaleYMin as string) + "|" + \
        (preset.scaleYMax as string) + "|" + \
        (preset.scaleZMin as string) + "|" + \
        (preset.scaleZMax as string) + "|" + \
        (boolText preset.isCustom)
    ),

    fn presetFromLine line =
    (
        local parts = filterString line "|"
        if parts.count < 14 then undefined else
        (
            local sMin = parts[13] as float
            local sMax = parts[14] as float
            local sxMin = if parts.count >= 20 then (parts[15] as float) else sMin
            local sxMax = if parts.count >= 20 then (parts[16] as float) else sMax
            local syMin = if parts.count >= 20 then (parts[17] as float) else sMin
            local syMax = if parts.count >= 20 then (parts[18] as float) else sMax
            local szMin = if parts.count >= 20 then (parts[19] as float) else sMin
            local szMax = if parts.count >= 20 then (parts[20] as float) else sMax
            local presetName = if parts[1] == "Neutral" then "Default settings" else parts[1]
            local customFlag = if parts.count >= 21 then (boolFromText parts[21]) else not (presetName == "Default settings" or presetName == "Subtle Position" or presetName == "Rotation Variation" or presetName == "Scale Variation" or presetName == "Full Variation")

            RTPreset \
                name:presetName \
                seedValue:(parts[2] as integer) \
                posEnabled:(boolFromText parts[3]) \
                rotEnabled:(boolFromText parts[4]) \
                scaleEnabled:(boolFromText parts[5]) \
                uniformEnabled:(boolFromText parts[6]) \
                posX:(parts[7] as float) \
                posY:(parts[8] as float) \
                posZ:(parts[9] as float) \
                rotX:(parts[10] as float) \
                rotY:(parts[11] as float) \
                rotZ:(parts[12] as float) \
                scaleMin:sMin \
                scaleMax:sMax \
                scaleXMin:sxMin \
                scaleXMax:sxMax \
                scaleYMin:syMin \
                scaleYMax:syMax \
                scaleZMin:szMin \
                scaleZMax:szMax \
                isCustom:customFlag
        )
    ),

    fn loadPresets =
    (
        presets = #()
        local path = presetStoragePath()

        if doesFileExist path do
        (
            local f = openFile path mode:"r"
            while not eof f do
            (
                local line = readLine f
                local preset = presetFromLine line
                if preset != undefined do
                (
                    append presets preset
                )
            )
            close f
        )

        if presets.count == 0 do presets = stockPresets()
        currentPresetIndex = 1
    ),

    fn savePresets =
    (
        local path = presetStoragePath()
        local f = createFile path
        for preset in presets do
            format "%\n" (presetToLine preset) to:f
        close f
    ),

    fn currentPresetName =
    (
        if presets.count == 0 or currentPresetIndex < 1 or currentPresetIndex > presets.count then "No presets" else presets[currentPresetIndex].name
    ),

    fn presetNameExists candidate =
    (
        for preset in presets where preset.name == candidate do return true
        false
    ),

    fn presetIndexByName candidate =
    (
        for i = 1 to presets.count where presets[i].name == candidate do return i
        0
    ),

    fn defaultPresetIndex =
    (
        local idx = presetIndexByName "Default settings"
        if idx == 0 do idx = 1
        idx
    ),

    fn isDefaultPresetIndex index =
    (
        index == defaultPresetIndex()
    ),

    fn customPresetCount =
    (
        local count = 0
        for preset in presets where preset.isCustom do count += 1
        count
    ),

    fn createThemedDialog title w h =
    (
        local dialog = dotNetObject "System.Windows.Forms.Form"
        dialog.Text = title
        dialog.ClientSize = dotNetObject "System.Drawing.Size" w h
        dialog.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").FixedDialog
        if form != undefined then
            dialog.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").CenterParent
        else
            dialog.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").CenterScreen
        dialog.AutoScaleMode = (dotNetClass "System.Windows.Forms.AutoScaleMode").None
        dialog.ShowIcon = false
        dialog.MaximizeBox = false
        dialog.MinimizeBox = false
        dialog.TopMost = if form != undefined then form.TopMost else false
        dialog.BackColor = colorBackground()
        dialog
    ),

    fn styleDialogButton btn role =
    (
        btn.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
        btn.UseVisualStyleBackColor = false
        btn.BackColor = if role == #primary then colorPrimaryButton() else colorSecondaryButton()
        btn.ForeColor = if role == #primary then colorPrimaryButtonText() else colorText()
        btn.Font = fontButton
        btn.FlatAppearance.BorderColor = colorBorder()
        btn.FlatAppearance.BorderSize = 1
        btn
    ),

    fn addHiddenDialogButton dialog resultName =
    (
        local resultClass = dotNetClass "System.Windows.Forms.DialogResult"
        local btn = dotNetObject "System.Windows.Forms.Button"
        btn.SetBounds -100 -100 1 1
        btn.TabStop = false
        btn.DialogResult = if resultName == "OK" then resultClass.OK else resultClass.Cancel
        dialog.Controls.Add btn
        btn
    ),

    fn createDialogButton dialog name text x y w h role resultName =
    (
        local panel = dotNetObject "System.Windows.Forms.Panel"
        panel.Name = name
        panel.Text = text
        panel.Tag = if role == #primary then "primary" else "secondary"
        panel.AccessibleDescription = resultName
        panel.AccessibleName = ""
        panel.BackColor = colorBackground()
        panel.Cursor = (dotNetClass "System.Windows.Forms.Cursors").Hand
        panel.SetBounds x y w h
        dotNet.addEventHandler panel "Paint" RT_dialogButtonPaint
        dotNet.addEventHandler panel "MouseEnter" RT_dialogButtonEnter
        dotNet.addEventHandler panel "MouseLeave" RT_dialogButtonLeave
        dotNet.addEventHandler panel "Click" RT_dialogButtonClick
        dialog.Controls.Add panel
        panel.BringToFront()
        panel
    ),

    fn addDialogLabel dialog text x y w h role =
    (
        local lbl = dotNetObject "System.Windows.Forms.Label"
        lbl.Text = text
        lbl.AutoSize = false
        lbl.BackColor = colorBackground()
        lbl.ForeColor = labelRoleColor role
        lbl.Font = fontBody
        lbl.TextAlign = (dotNetClass "System.Drawing.ContentAlignment").MiddleLeft
        lbl.SetBounds x y w h
        dialog.Controls.Add lbl
        lbl
    ),

    fn showNotice message =
    (
        try
        (
            local dialog = createThemedDialog "Randomize Transform" 420 150
            addDialogLabel dialog message 24 22 372 64 #primary

            local okButton = addHiddenDialogButton dialog "OK"
            dialog.AcceptButton = okButton
            dialog.CancelButton = okButton
            createDialogButton dialog "noticeOk" "OK" 284 96 112 34 #primary "OK"

            if form != undefined then
                dialog.ShowDialog form
            else
                dialog.ShowDialog()

            dialog.Dispose()
        )
        catch()
    ),

    fn showConfirm message yesText noText =
    (
        local accepted = false

        try
        (
            local dialogResultClass = dotNetClass "System.Windows.Forms.DialogResult"
            local dialog = createThemedDialog "Randomize Transform" 460 170
            addDialogLabel dialog message 24 22 412 70 #primary

            local noButton = addHiddenDialogButton dialog "Cancel"
            local yesButton = addHiddenDialogButton dialog "OK"

            dialog.AcceptButton = yesButton
            dialog.CancelButton = noButton
            createDialogButton dialog "confirmNo" noText 220 112 100 34 #secondary "Cancel"
            createDialogButton dialog "confirmYes" yesText 336 112 100 34 #primary "OK"

            local result = if form != undefined then (dialog.ShowDialog form) else (dialog.ShowDialog())
            accepted = result == dialogResultClass.OK

            dialog.Dispose()
        )
        catch
        (
            accepted = false
        )

        accepted
    ),

    fn promptPresetName defaultName =
    (
        local result = undefined
        try
        (
            local dialogResultClass = dotNetClass "System.Windows.Forms.DialogResult"
            local dialog = createThemedDialog "Preset Name" 420 180
            addDialogLabel dialog "Preset name:" 24 22 372 22 #primary

            local fieldPanel = dotNetObject "System.Windows.Forms.Panel"
            fieldPanel.Name = "presetNameField"
            fieldPanel.AccessibleName = ""
            fieldPanel.BackColor = colorBackground()
            fieldPanel.SetBounds 24 54 372 34
            dotNet.addEventHandler fieldPanel "Paint" RT_dialogFieldPaint
            dotNet.addEventHandler fieldPanel "MouseEnter" RT_dialogFieldEnter
            dotNet.addEventHandler fieldPanel "MouseLeave" RT_dialogFieldLeave

            local tb = dotNetObject "System.Windows.Forms.TextBox"
            tb.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").None
            tb.BackColor = colorSecondaryButton()
            tb.ForeColor = colorText()
            tb.Font = fontBody
            tb.Text = defaultName
            tb.SetBounds 12 8 348 18
            dotNet.addEventHandler tb "MouseEnter" RT_dialogFieldEnter
            dotNet.addEventHandler tb "MouseLeave" RT_dialogFieldLeave
            dotNet.addEventHandler tb "Enter" RT_inputFocusEnter
            dotNet.addEventHandler tb "Leave" RT_inputFocusLeave
            fieldPanel.Controls.Add tb
            dialog.Controls.Add fieldPanel
            fieldPanel.BringToFront()

            local cancelButton = addHiddenDialogButton dialog "Cancel"
            local okButton = addHiddenDialogButton dialog "OK"

            dialog.AcceptButton = okButton
            dialog.CancelButton = cancelButton
            createDialogButton dialog "nameCancel" "CANCEL" 172 118 108 34 #secondary "Cancel"
            createDialogButton dialog "nameOk" "SAVE" 292 118 104 34 #primary "OK"
            dialog.ActiveControl = tb
            try (tb.SelectAll()) catch()

            local dialogResult = if form != undefined then (dialog.ShowDialog form) else (dialog.ShowDialog())
            if dialogResult == dialogResultClass.OK do
                result = tb.Text

            dialog.Dispose()
        )
        catch()

        if result == undefined or result == "" then undefined else cleanPresetName result
    ),

    fn presetFromCurrentValues name =
    (
        RTPreset \
            name:name \
            seedValue:(getInputValue "seed") \
            posEnabled:(getToggleValue "posEnable" true) \
            rotEnabled:(getToggleValue "rotEnable" true) \
            scaleEnabled:(getToggleValue "scaleEnable" true) \
            uniformEnabled:(getToggleValue "uniformScale" true) \
            posX:(getInputValue "posX") \
            posY:(getInputValue "posY") \
            posZ:(getInputValue "posZ") \
            rotX:(getInputValue "rotX") \
            rotY:(getInputValue "rotY") \
            rotZ:(getInputValue "rotZ") \
            scaleMin:(getInputValue "scaleMin") \
            scaleMax:(getInputValue "scaleMax") \
            scaleXMin:(getInputValue "scaleXMin") \
            scaleXMax:(getInputValue "scaleXMax") \
            scaleYMin:(getInputValue "scaleYMin") \
            scaleYMax:(getInputValue "scaleYMax") \
            scaleZMin:(getInputValue "scaleZMin") \
            scaleZMax:(getInputValue "scaleZMax") \
            isCustom:true
    ),

    fn updatePresetButton =
    (
        setButtonText "presetDrop" (if presetDirty then "" else currentPresetName())
    ),

    fn markPresetDirty =
    (
        if not presetDirty do
        (
            presetDirty = true
            updatePresetButton()
        )
    ),

    fn ensureSelectionCaptured =
    (
        local sig = RT_RandomTransformUI.getSelectionSignature()
        if items.count == 0 or sig != lastSelectionSignature do
        (
            RT_RandomTransformUI.revertObjects()
            RT_RandomTransformUI.captureObjects()
        )
    ),

    fn createPresetMenuItem itemIndex y =
    (
        local panel = dotNetObject "System.Windows.Forms.Panel"
        local itemName = "presetItem_" + (itemIndex as string)
        panel.Name = itemName
        panel.BackColor = colorBackground()
        panel.Cursor = (dotNetClass "System.Windows.Forms.Cursors").Hand
        setControlBounds panel 6 y (presetMenu.Width - 12) 28
        dotNet.addEventHandler panel "Paint" RT_buttonPaint
        dotNet.addEventHandler panel "MouseEnter" RT_buttonEnter
        dotNet.addEventHandler panel "MouseLeave" RT_buttonLeave
        dotNet.addEventHandler panel "MouseDown" RT_buttonMouseDown
        dotNet.addEventHandler panel "Click" RT_buttonClick
        presetMenu.Controls.Add panel
        panel.BringToFront()
        append buttons (RTButtonState name:itemName ctrl:panel text:presets[itemIndex].name role:#secondary)
        panel
    ),

    fn rebuildPresetMenu =
    (
        if presetMenu == undefined do return false

        for i = buttons.count to 1 by -1 do
        (
            if matchPattern buttons[i].name pattern:"presetItem_*" do
                deleteItem buttons i
        )

        presetMenu.Controls.Clear()
        local menuHeight = 12 + (presets.count * 30)
        if menuHeight < 48 do menuHeight = 48
        presetMenu.Height = menuHeight

        for i = 1 to presets.count do
            createPresetMenuItem i (6 + ((i - 1) * 30))

        presetMenu.Visible = false
    ),

    fn togglePresetMenu =
    (
        if presetMenu == undefined do return false
        presetMenu.Visible = not presetMenu.Visible
        presetMenu.BringToFront()
    ),

    fn hidePresetMenu =
    (
        if presetMenu != undefined do presetMenu.Visible = false
    ),

    fn saveCurrentPreset =
    (
        local customNumber = 1
        local candidate = "Custom " + (customNumber as string)

        while (presetNameExists candidate) do
        (
            customNumber += 1
            candidate = "Custom " + (customNumber as string)
        )

        local presetName = promptPresetName candidate
        if presetName == undefined do return false

        local existingIndex = presetIndexByName presetName
        if existingIndex > 0 and (isDefaultPresetIndex existingIndex) do
        (
            showNotice "Default settings cannot be overwritten."
            return false
        )

        if existingIndex > 0 do
        (
            if not (showConfirm ("Overwrite preset \"" + presetName + "\"?") "OVERWRITE" "CANCEL") do
                return false
        )

        local addsCustomPreset = existingIndex == 0
        if existingIndex > 0 do addsCustomPreset = not presets[existingIndex].isCustom

        if addsCustomPreset and customPresetCount() >= 20 do
        (
            showNotice "You can save up to 20 custom presets."
            return false
        )

        if existingIndex > 0 then
        (
            presets[existingIndex] = presetFromCurrentValues presetName
            currentPresetIndex = existingIndex
        )
        else
        (
            append presets (presetFromCurrentValues presetName)
            currentPresetIndex = presets.count
        )

        presetDirty = false
        savePresets()
        rebuildPresetMenu()
        updatePresetButton()
    ),

    fn renamePreset index =
    (
        if index < 1 or index > presets.count do return false
        if isDefaultPresetIndex index do
        (
            showNotice "Default settings cannot be renamed."
            return false
        )

        local oldName = presets[index].name
        local newName = promptPresetName oldName
        if newName == undefined or newName == oldName do return false

        local existingIndex = presetIndexByName newName
        if existingIndex > 0 and existingIndex != index do
        (
            showNotice "A preset with that name already exists."
            return false
        )

        local renamedPreset = presets[index]
        renamedPreset.name = newName
        presets[index] = renamedPreset
        savePresets()
        rebuildPresetMenu()
        updatePresetButton()
    ),

    fn deleteCurrentPreset =
    (
        if presets.count == 0 do return false
        if isDefaultPresetIndex currentPresetIndex do
        (
            showNotice "Default settings cannot be deleted."
            return false
        )

        deleteItem presets currentPresetIndex
        if presets.count == 0 do append presets (RTPreset name:"Default settings" seedValue:12345 scaleMin:100 scaleMax:100 scaleXMin:100 scaleXMax:100 scaleYMin:100 scaleYMax:100 scaleZMin:100 scaleZMax:100)
        if currentPresetIndex > presets.count do currentPresetIndex = presets.count

        savePresets()
        rebuildPresetMenu()
        RT_RandomTransformUI.applyPreset currentPresetIndex
    ),

    fn getSelectionSignature =
    (
        local s = ""
        for obj in selection do s += (obj.handle as string) + "|"
        s
    ),

    fn wrapHashValue value =
    (
        local modulus = 2147483647.0
        local wrapped = value - ((floor (value / modulus)) * modulus)
        if wrapped < 0.0 do wrapped += modulus
        wrapped
    ),

    fn seededUnit seedValue objectKey salt =
    (
        local x = wrapHashValue ((((seedValue as float) + 1.0) * 48271.0) + (((objectKey as float) + 1.0) * 69621.0) + ((salt as float) * 19937.0) + 12345.0)
        x = wrapHashValue ((x * 48271.0) + ((salt as float) * 3877.0) + 76543.0)
        x = wrapHashValue ((x * 48271.0) + ((objectKey as float) * 1697.0) + 24691.0)
        x / 2147483647.0
    ),

    fn seededSigned seedValue objectKey salt =
    (
        ((seededUnit seedValue objectKey salt) * 2.0) - 1.0
    ),

    fn captureObjects =
    (
        items = #()
        applied = false
        local seedValue = getInputValue "seed"
        local objectIndex = 0

        for obj in selection where isValidNode obj do
        (
            objectIndex += 1
            local objectKey = objectIndex as float
            try (objectKey = (obj.handle as float) + ((objectIndex as float) * 9973.0)) catch()

            append items (RTData \
                node:obj \
                baseTM:obj.transform \
                randPos:[seededSigned seedValue objectKey 101.0, seededSigned seedValue objectKey 102.0, seededSigned seedValue objectKey 103.0] \
                randRot:[seededSigned seedValue objectKey 201.0, seededSigned seedValue objectKey 202.0, seededSigned seedValue objectKey 203.0] \
                randScale:[seededUnit seedValue objectKey 301.0, seededUnit seedValue objectKey 302.0, seededUnit seedValue objectKey 303.0]
            )
        )

        lastSelectionSignature = getSelectionSignature()
    ),

    fn revertObjects =
    (
        for d in items where isValidNode d.node do
            d.node.transform = d.baseTM
    ),

    fn updatePreview =
    (
        if busy or closingNow or items.count == 0 do return false
        busy = true

        local posEnabled = getToggleValue "posEnable" true
        local rotEnabled = getToggleValue "rotEnable" true
        local scaleEnabled = getToggleValue "scaleEnable" true
        local uniformEnabled = getToggleValue "uniformScale" true

        local posX = getInputValue "posX"
        local posY = getInputValue "posY"
        local posZ = getInputValue "posZ"
        local rotX = getInputValue "rotX"
        local rotY = getInputValue "rotY"
        local rotZ = getInputValue "rotZ"
        local minScaleValue = getInputValue "scaleMin"
        local maxScaleValue = getInputValue "scaleMax"
        local minS = minScaleValue / 100.0
        local maxS = maxScaleValue / 100.0
        local xMinS = (getInputValue "scaleXMin") / 100.0
        local xMaxS = (getInputValue "scaleXMax") / 100.0
        local yMinS = (getInputValue "scaleYMin") / 100.0
        local yMaxS = (getInputValue "scaleYMax") / 100.0
        local zMinS = (getInputValue "scaleZMin") / 100.0
        local zMaxS = (getInputValue "scaleZMax") / 100.0

        if maxS < minS do
        (
            local tmp = minS
            minS = maxS
            maxS = tmp
        )

        if xMaxS < xMinS do
        (
            local tmp = xMinS
            xMinS = xMaxS
            xMaxS = tmp
        )

        if yMaxS < yMinS do
        (
            local tmp = yMinS
            yMinS = yMaxS
            yMaxS = tmp
        )

        if zMaxS < zMinS do
        (
            local tmp = zMinS
            zMinS = zMaxS
            zMaxS = tmp
        )

        for d in items where isValidNode d.node do
        (
            local n = d.node

            n.transform = d.baseTM

            if posEnabled do
            (
                n.position = d.baseTM.position + [ \
                    d.randPos.x * posX, \
                    d.randPos.y * posY, \
                    d.randPos.z * posZ \
                ]
            )

            if rotEnabled do
            (
                local rx = d.randRot.x * rotX
                local ry = d.randRot.y * rotY
                local rz = d.randRot.z * rotZ
                in coordsys local rotate n (eulerAngles rx ry rz)
            )

            if scaleEnabled do
            (
                local sx, sy, sz

                if uniformEnabled then
                (
                    sx = sy = sz = minS + ((maxS - minS) * d.randScale.x)
                )
                else
                (
                    sx = xMinS + ((xMaxS - xMinS) * d.randScale.x)
                    sy = yMinS + ((yMaxS - yMinS) * d.randScale.y)
                    sz = zMinS + ((zMaxS - zMinS) * d.randScale.z)
                )

                in coordsys local scale n [sx,sy,sz]
            )
        )

        busy = false
    ),

    fn applyPreset index =
    (
        if index < 1 or index > presets.count do return false

        currentPresetIndex = index
        local preset = presets[index]

        setToggleValue "posEnable" preset.posEnabled
        setToggleValue "rotEnable" preset.rotEnabled
        setToggleValue "scaleEnable" preset.scaleEnabled
        setToggleValue "uniformScale" preset.uniformEnabled

        setInputValue "seed" preset.seedValue false
        setInputValue "posX" preset.posX false
        setInputValue "posY" preset.posY false
        setInputValue "posZ" preset.posZ false
        setInputValue "rotX" preset.rotX false
        setInputValue "rotY" preset.rotY false
        setInputValue "rotZ" preset.rotZ false
        setInputValue "scaleMin" preset.scaleMin false
        setInputValue "scaleMax" preset.scaleMax false
        setInputValue "scaleXMin" preset.scaleXMin false
        setInputValue "scaleXMax" preset.scaleXMax false
        setInputValue "scaleYMin" preset.scaleYMin false
        setInputValue "scaleYMax" preset.scaleYMax false
        setInputValue "scaleZMin" preset.scaleZMin false
        setInputValue "scaleZMax" preset.scaleZMax false

        enforceScaleRanges ""
        presetDirty = false
        updatePresetButton()
        updateScaleInputVisibility()
        hidePresetMenu()
        revertObjects()
        captureObjects()
        updatePreview()
    ),

    fn autoCaptureIfNeeded =
    (
        if closingNow do return false

        local sig = getSelectionSignature()

        if sig != lastSelectionSignature do
        (
            revertObjects()
            captureObjects()
            updatePreview()
        )
    ),

    fn inputChanged name =
    (
        if suppressTextEvents or closingNow do return false
        markPresetDirty()

        if name == "seed" then
        (
            revertObjects()
            captureObjects()
            updatePreview()
        )
        else
        (
            enforceScaleRanges name
            ensureSelectionCaptured()
            updatePreview()
        )
    ),

    fn toggleChanged name =
    (
        local idx = toggleIndex name
        if idx == 0 do return false
        toggles[idx].checked = not toggles[idx].checked
        toggles[idx].ctrl.Invalidate()
        markPresetDirty()
        if name == "uniformScale" do updateScaleInputVisibility()
        ensureSelectionCaptured()
        updatePreview()
    ),

    fn buttonMouseDown name args =
    (
        if args.Button != (dotNetClass "System.Windows.Forms.MouseButtons").Right do return false

        if name == "presetDrop" then
        (
            suppressClickName = name
            if presetDirty do return false
            renamePreset currentPresetIndex
        )
        else
        (
            if matchPattern name pattern:"presetItem_*" do
            (
                suppressClickName = name
                local indexText = substring name 12 (name.count - 11)
                local index = indexText as integer
                renamePreset index
            )
        )
    ),

    fn handleButton name =
    (
        if suppressClickName == name do
        (
            suppressClickName = ""
            return false
        )

        if matchPattern name pattern:"presetItem_*" then
        (
            local indexText = substring name 12 (name.count - 11)
            local index = indexText as integer
            applyPreset index
        )
        else case name of
        (
            "presetDrop":
            (
                togglePresetMenu()
            )

            "presetSave":
            (
                saveCurrentPreset()
            )

            "presetDelete":
            (
                deleteCurrentPreset()
            )

            "apply":
            (
                applied = true
                items = #()
                lastSelectionSignature = getSelectionSignature()
            )

            "revert":
            (
                revertObjects()
                items = #()
                applied = false
                applyPreset (defaultPresetIndex())
            )

            "theme":
            (
                darkMode = not darkMode
                applyTheme()
            )

            "pin":
            (
                topPinned = not topPinned
                if form != undefined do form.TopMost = topPinned
                setButtonText "pin" (iconPin())
            )
        )
    ),

    fn handleClosing =
    (
        closingNow = true
        setTextEditing false
        try (if timer != undefined do timer.Stop()) catch()

        if not applied do
            revertObjects()
    ),

    fn build =
    (
        form = dotNetObject "System.Windows.Forms.Form"
        form.Text = "Randomize Transform"
        form.ClientSize = dotNetObject "System.Drawing.Size" 640 752
        form.MinimumSize = dotNetObject "System.Drawing.Size" 656 791
        form.MaximumSize = dotNetObject "System.Drawing.Size" 656 791
        form.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").FixedSingle
        form.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").CenterScreen
        form.AutoScaleMode = (dotNetClass "System.Windows.Forms.AutoScaleMode").None
        form.ShowIcon = false
        form.MaximizeBox = false
        form.TopMost = false
        form.BackColor = colorBackground()

        loadPresets()

        createLabel "Randomize Transform" 24 20 460 40 #primary fontTitle
        createLabel "Perform randomized transform operations in real-time, to one or more" 26 62 548 18 #secondary fontBody
        createLabel "selected objects." 26 80 548 18 #secondary fontBody
        createButton "pin" (iconPin()) 548 24 36 32 #secondary
        createButton "theme" (iconMoon()) 592 24 36 32 #secondary

        createCard "presetCard" 24 116 420 100
        createLabel "PRESETS" 44 134 160 18 #header fontHeader
        createButton "presetDrop" (currentPresetName()) 44 166 216 32 #secondary
        createButton "presetSave" "SAVE" 270 166 62 32 #secondary
        createButton "presetDelete" "DELETE" 340 166 70 32 #secondary

        createCard "seedCard" 460 116 156 100
        createLabel "RANDOM SEED" 480 134 120 18 #header fontHeader
        createInput "seed" "" 480 166 116 12345 1 2147483646 true

        presetMenu = dotNetObject "System.Windows.Forms.Panel"
        presetMenu.Name = "presetMenu"
        presetMenu.BackColor = colorBackground()
        setControlBounds presetMenu 44 198 216 48
        presetMenu.Visible = false
        dotNet.addEventHandler presetMenu "Paint" RT_cardPaint
        form.Controls.Add presetMenu
        presetMenu.BringToFront()
        rebuildPresetMenu()

        createCard "positionCard" 24 238 286 150
        createLabel "POSITION" 44 256 180 18 #header fontHeader
        createToggle "posEnable" "Position" 44 284 true
        createInput "posX" "X +/-" 44 340 78 0.0 0.0 100000.0 false
        createInput "posY" "Y +/-" 128 340 78 0.0 0.0 100000.0 false
        createInput "posZ" "Z +/-" 212 340 78 0.0 0.0 100000.0 false

        createCard "rotationCard" 330 238 286 150
        createLabel "ROTATION" 350 256 180 18 #header fontHeader
        createToggle "rotEnable" "Rotation" 350 284 true
        createInput "rotX" "X +/-" 350 340 78 0.0 0.0 360.0 false
        createInput "rotY" "Y +/-" 434 340 78 0.0 0.0 360.0 false
        createInput "rotZ" "Z +/-" 518 340 78 0.0 0.0 360.0 false

        createCard "scaleCard" 24 410 592 222
        createLabel "SCALE" 44 428 160 18 #header fontHeader
        createToggle "scaleEnable" "Scale" 44 456 true
        createToggle "uniformScale" "Uniform scale" 164 456 true
        createInput "scaleMin" "Min %" 44 512 260 100.0 1.0 10000.0 false
        createInput "scaleMax" "Max %" 336 512 260 100.0 1.0 10000.0 false
        createInput "scaleXMin" "X Min %" 44 512 160 100.0 1.0 10000.0 false
        createInput "scaleYMin" "Y Min %" 230 512 160 100.0 1.0 10000.0 false
        createInput "scaleZMin" "Z Min %" 416 512 160 100.0 1.0 10000.0 false
        createInput "scaleXMax" "X Max %" 44 580 160 100.0 1.0 10000.0 false
        createInput "scaleYMax" "Y Max %" 230 580 160 100.0 1.0 10000.0 false
        createInput "scaleZMax" "Z Max %" 416 580 160 100.0 1.0 10000.0 false

        updateScaleInputVisibility()

        createButton "apply" "APPLY / KEEP RESULT" 24 586 286 38 #primary
        createButton "revert" "REVERT" 330 586 286 38 #secondary

        local creditText = "Script by Afonso Goncalves. https://www.afoviz.com."
        creditLabel = dotNetObject "System.Windows.Forms.LinkLabel"
        creditLabel.Text = creditText
        creditLabel.AutoSize = false
        creditLabel.BackColor = colorBackground()
        creditLabel.ForeColor = colorSecondaryText()
        creditLabel.LinkColor = colorSecondaryText()
        creditLabel.ActiveLinkColor = colorText()
        creditLabel.VisitedLinkColor = colorSecondaryText()
        creditLabel.Font = fontCredit
        creditLabel.TextAlign = (dotNetClass "System.Drawing.ContentAlignment").MiddleLeft
        creditLabel.LinkBehavior = (dotNetClass "System.Windows.Forms.LinkBehavior").HoverUnderline
        creditLabel.Links.Clear()
        creditLabel.Links.Add 0 creditText.count "https://www.afoviz.com"
        setControlBounds creditLabel 24 638 592 22
        form.Controls.Add creditLabel
        creditLabel.BringToFront()
        append labels (RTLabelState ctrl:creditLabel role:#credit)
        creditLabel.Cursor = (dotNetClass "System.Windows.Forms.Cursors").Hand
        dotNet.addEventHandler creditLabel "MouseEnter" RT_creditEnter
        dotNet.addEventHandler creditLabel "MouseLeave" RT_creditLeave
        dotNet.addEventHandler creditLabel "LinkClicked" RT_creditClick

        applyTheme()
        RT_RandomTransformUI.applyPreset currentPresetIndex

        dotNet.addEventHandler form "FormClosing" RT_formClosing

        timer = dotNetObject "System.Windows.Forms.Timer"
        timer.Interval = 300
        dotNet.addEventHandler timer "Tick" RT_timerTick
        timer.Start()

        form.Show()
    )
)

RT_RandomTransformUI = RTRandomTransformUI()
RT_RandomTransformUI.build()
