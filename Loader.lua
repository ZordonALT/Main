local func = Instance.new("BindableFunction")

func.OnInvoke = function()
    setclipboard("https://projectevo.xyz/discord")
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Update",
    Text = "This version of Project: Evolution is outdated",
    Button1 = "Copy Discord",
    Callback = func
})
