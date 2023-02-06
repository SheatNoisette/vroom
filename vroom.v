module main

import os
import malisipi.mui

const (
	program_name = "VRoom"
	cflags_string = " -cflags \"-Oz -s -w -fno-stack-protector -fno-math-errno -Wl,-z,norelro -Wl,--hash-style=gnu -fdata-sections -ffunction-sections -Wl,--build-id=none -Wl,--gc-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -lgc\""
	available_ccs = get_available_ccs()
)

enum WarnType as int {
	not_found
}

fn get_available_ccs () []string {
	mut ccs := ["tcc"]
	for cc in ["gcc","clang"]{
		if os.exists_in_system_path(cc) {
			ccs << cc
		}
	}
	return ccs
}

fn warn_user(warn_type WarnType, warn_info string, gui bool) bool {
	mut warn_message := ""
	match warn_type {
		.not_found {
			warn_message = "${warn_info} is not found"
		}
	}
	if gui {
		mui.messagebox(program_name, warn_message, "ok", "warning")
	} else {
		println("WARN: ${warn_message}")
	}
	return false
}

fn compile_code_gui(event_details mui.EventDetails, mut app &mui.Window, mut app_data voidptr){
	unsafe {
		go compile_code_async(
			mut app,
			app.get_object_by_id("input_file")[0]["text"].str,
			app.get_object_by_id("output_file")[0]["text"].str,
			app.get_object_by_id("cc")[0]["text"].str,
			app.get_object_by_id("strip")[0]["c"].bol,
			app.get_object_by_id("compress")[0]["c"].bol,
			app.get_object_by_id("cflags")[0]["c"].bol
		)
	}
}

fn compile_code_async(mut app &mui.Window, input_file string, output_file string, cc string, strip bool, compress bool, cflags bool){
	unsafe {
		button := app.get_object_by_id("compile")[0]
		button["text"].str = "Compiling... Please wait a moment"
		compile_code(input_file, output_file, cc, strip, compress, cflags, true)
		button["text"].str = "Compile"
		mui.messagebox(program_name, "Compiled!", "ok", "info")
	}
}

fn compile_code(input_file string, output_file string, cc string, strip bool, compress bool, cflags bool, gui bool) {
	mut v_command := "v -skip-unused -cc ${cc} \"${input_file}\" -o \"${output_file}\""
	if strip && (os.exists_in_system_path("strip") || warn_user(.not_found, "strip", gui) ) {
		v_command += " -strip"
	}
	if compress && (os.exists_in_system_path("upx") || warn_user(.not_found, "upx", gui) )  {
		v_command += " -compress"
	}
	if cflags {
		v_command += cflags_string
	}
	os.system(v_command)
}

fn select_file(event_details mui.EventDetails, mut app &mui.Window, mut app_data voidptr){
	app.get_object_by_id(event_details.target_id)[0]["text"].str = if event_details.target_id=="input_file" {
		mui.openfiledialog(program_name)
	} else {
		mui.savefiledialog(program_name)
	}
}

fn main(){
	if os.args.len > 2 && os.args[2]=="-o" { //TODO: Make better command line interface
		compile_code(os.args[1], os.args[3], "clang", true, true, true, false)
	} else {
		mut app := mui.create(title:program_name, width:600, height:300)
		app.label(id:"program_name", x:20, y:20, width:"100%x -40", height:40, text:program_name, text_size:30)
		app.button(id:"input_file", x:20, y:70, width:"100%x -40", height:20, text:"Select Input File", onclick:select_file)
		app.button(id:"output_file", x:20, y:100, width:"100%x -40", height:20, text:"Select Output File", onclick:select_file)
		app.label(id:"cc_label", x:20, y:130, width:100, height:20, text:"C Compiler", text_align: 0)
		app.selectbox(id:"cc", x:"# 20", y:130, width:"100%x -140", height:20, list:available_ccs)
		app.switch(id:"strip", x:20, y:160, width:40, height:20, text:"Strip", checked:true)
		app.switch(id:"compress", x:20, y:190, width:40, height:20, text:"Compress", checked:true)
		app.switch(id:"cflags", x:20, y:220, width:40, height:20, text:"Extra Cflags", checked:true)
		app.button(id:"compile", x:20, y:250, width:"100%x -40", height:20, text:"Compile", onclick:compile_code_gui)
		app.run()
	}
}
