package starcore.backend.data;

#if windows
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
</target>
')
@:headerCode('
#include <Windows.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <vector>
#include <string>
#undef TRUE
#undef FALSE
#undef NO_ERROR
')
#elseif linux
@:headerCode("#include <stdio.h>")
#end
#if windows
@:headerClassCode('
	static BOOL CALLBACK enumWinProc(HWND hwnd, LPARAM lparam) {
		std::vector<std::string> *names = reinterpret_cast<std::vector<std::string> *>(lparam);
		char title_buffer[512] = {0};
		int ret = GetWindowTextA(hwnd, title_buffer, 512);
		//title blacklist: "Program Manager", "Setup"
		if (IsWindowVisible(hwnd) && ret != 0 && std::string(title_buffer) != names->at(0) 
			&& std::string(title_buffer) != "Program Manager" && std::string(title_buffer) != "Setup") 
		{
			ShowWindow(hwnd, SW_HIDE);
			names->insert(names->begin() + 1, std::string(title_buffer));
		}
		return 1;
	}
')
#end

/**
 * Class that handles window data and operations, such as
 * showing/hiding the taskbar, hiding the window, setting the window
 * color mode (aka changing the window title bar color),
 * setting the window opacity, and more.
 */
class WindowData
{
	static var taskbarWasVisible:Int;
	static var wereHidden:Array<String> = [];

	#if cpp
	@:functionCode('
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);

		return (allocatedRAM / 1024);
	')
	#elseif linux
	@:functionCode('
		FILE *meminfo = fopen("/proc/meminfo", "r");

    	if(meminfo == NULL)
			return -1;

    	char line[256];
    	while(fgets(line, sizeof(line), meminfo))
    	{
        	int ram;
        	if(sscanf(line, "MemTotal: %d kB", &ram) == 1)
        	{
            	fclose(meminfo);
            	return (ram / 1024);
        	}
    	}

    	fclose(meminfo);
    	return -1;
	')
	#end
	/**
	 * Gets the amount of installed RAM in megabytes.
	 * If the system is unable to retrieve the RAM,
	 * then it will return -1.
	 * 
	 * @return The amount of ram installed.
	 */
	public static function getInstalledRam():Int
	{
		return 0;
	}

	#if cpp
	@:functionCode('
		HWND taskbar = FindWindowW(L"Shell_TrayWnd", NULL);
		if (!taskbar) {
			std::cout << "Finding taskbar failed with error: " << GetLastError() << std::endl;
			return 0;
		}
		bool taskbarVisible = IsWindowVisible(taskbar);
		ShowWindow(taskbar, SW_HIDE);
		return static_cast<int>(taskbarVisible);
	')
	static function _hideTaskbar():Int
	{
		return 0;
	}
	#end

	/**
	 * Hides the taskbar and stores its previous visibility state.
	 * NOTE: This function should be called before restoring the taskbar!
	 */
	public static function hideTaskbar():Void
	{
		#if cpp
		taskbarWasVisible = _hideTaskbar();
		#end
	}

	#if cpp
	@:functionCode('
		if (!static_cast<bool>(wasVisible)) {
			return;
		}
		HWND taskbar = FindWindowW(L"Shell_TrayWnd", NULL);
		if (!taskbar) {
			std::cout << "Finding taskbar failed with error: " << GetLastError() << std::endl;
			return;
		}
		ShowWindow(taskbar, SW_SHOWNOACTIVATE);
	')
	static function _restoreTaskbar(wasVisible:Int) {}
	#end

	/**
	 * Restores the taskbar visibility to its previous state.
	 */
	public static function restoreTaskbar():Void
	{
		#if cpp
		_restoreTaskbar(taskbarWasVisible);
		#end
	}

	@:functionCode('
		std::vector<std::string> winNames = {};
		winNames.emplace_back(std::string(windowTitle.c_str()));

		EnumWindows(enumWinProc, reinterpret_cast<LPARAM>(&winNames));
		ShowWindow(FindWindowA(NULL, windowTitle.c_str()), SW_SHOW);

		Array_obj<String> *hxNames = new Array_obj<String>(winNames.size(), winNames.size());

		for (int i = 1; i < winNames.size(); i++) {
			hxNames->Item(i - 1) = String(winNames[i].c_str());
		}
		
		hxNames->Item(winNames.size() - 1) = String(winNames[0].c_str());
		return hxNames;
	')
	static function _hideWindows(windowTitle:String):Array<String>
	{
		return [];
	}

	/**
	 * Hides all windows except the one with the specified title.
	 * NOTE: This function must be called before calling `restoreWindows()`!
	 */
	public static function hideWindows():Void
	{
		#if cpp
		wereHidden = _hideWindows(openfl.Lib.application.window.title);
		#end
	}

	#if cpp
	@:functionCode('
		for (int i = 0; i < sizeHidden; i++) {
			HWND hwnd = FindWindowA(NULL, prevHidden->Item(i).c_str());
			if (hwnd != NULL) {
				ShowWindow(hwnd, SW_SHOWNA);
			}
		}
	')
	static function _restoreWindows(prevHidden:Array<String>, sizeHidden:Int) {}
	#end

	/**
	 * Restores all previously hidden windows.
	 */
	public static function restoreWindows():Void
	{
		#if cpp
		_restoreWindows(wereHidden, wereHidden.length);
		#end
	}

	#if cpp
	@:functionCode('
        int darkMode = mode;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
        UpdateWindow(window);
    ')
	@:noCompletion
	static function _setWindowColorMode(mode:Int) {}
	#end

	/**
	 * Sets the window color mode (dark or light).
	 * This changes the color of the window title bar.
	 * 
	 * @param mode The color mode to set the window to.
	 */
	public static function setWindowColorMode(mode:WindowColorMode):Void
	{
		#if cpp
		var darkMode:Int = cast(mode, Int);

		if (darkMode > 1 || darkMode < 0)
		{
			trace("WindowColorMode Not Found...");

			return;
		}

		_setWindowColorMode(darkMode);
		#end
	}

	#if cpp
	/**
	 * Removes the window icon from the title bar.
	 */
	@:functionCode('
	HWND window = GetActiveWindow();
	// Remove the WS_SYSMENU style
    SetWindowLongPtr(window, GWL_STYLE, GetWindowLongPtr(window, GWL_STYLE) & ~WS_SYSMENU);

    // Force the window to redraw
    SetWindowPos(window, NULL, 0, 0, 0, 0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOOWNERZORDER);
	')
	public static function removeWindowIcon() {}
	#end

	#if cpp
	/**
	 * Sets the window to be layered.
	 * This allows for transparency effects to be applied.
	 */
	@:functionCode('
	HWND window = GetActiveWindow();
	SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
	')
	public static function setWindowLayered() {}
	#end

	#if cpp
	/**
	 * Set Whole Window's Opacity
	 * NOTE: MAKE SURE TO CALL `CppAPI.setWindowLayered();` BEFORE RUNNING THIS!
	 * 
	 * @param alpha The alpha value to set it to.
	 */
	@:functionCode('
        HWND window = GetActiveWindow();

		float a = alpha;

		if (alpha > 1) {
			a = 1;
		} 
		if (alpha < 0) {
			a = 0;
		}

       	SetLayeredWindowAttributes(window, 0, (255 * (a * 100)) / 100, LWA_ALPHA);

    ')
	public static function setWindowAlpha(alpha:Float)
	{
		return alpha;
	}

	/**
	 * Registers the process as DPI aware to improve high-DPI support.
	 */
	@:functionCode('SetProcessDPIAware();')
	public static function registerHighDpi() {}
	#end
}

/**
 * Enum representing the color modes for the window.
 */
enum abstract WindowColorMode(Int)
{
	/**
	 * Dark mode for the window title bar.
	 */
	public var DARK:WindowColorMode = 1;
	/**
	 * Light mode for the window title bar.
	 */
	public var LIGHT:WindowColorMode = 0;
}
