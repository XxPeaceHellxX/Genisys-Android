{
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Author: PeratX
 * Genisys-Android Project
}

Program Genisys_Android;

{$mode objfpc}

Uses dos,sysutils;

Const 
	PROG_VER: string = 'v0.2.8 alpha';
	SHELL: string = '/system/bin/sh';

Var 
	HOME: string;
	WORKSPACE: string = '/sdcard/Genisys/';

Procedure testPerm;
Var 
	t: text;
Begin
	Try
		assign(t,HOME+'settings.conf');
		reset(t);
		close(t);
	Except
		on EInOutError Do
		Begin
			writeln('[ERROR] Unable to access '+HOME+'settings.conf : Permission denied !');
			halt;
		End;
		Else
			Begin
				writeln('[ERROR] Unable to access '+HOME+'settings.conf : Unknown error');
				halt;
			End;
	End;
End;

Procedure execBusybox(cmd:String;needLine:boolean = true);
Begin
	exec(HOME+'busybox', cmd);
	If needLine Then writeln;
End;

Procedure execPhp(homedir,fileName:String);

Var t: text;
Begin
	execBusybox('chmod 777 '+HOME+'php');//Set Perm
	assign(t,HOME+'temp.sh');
	rewrite(t);
	writeln(t,'cd '+WORKSPACE);
	writeln(t,'export TMPDIR='+WORKSPACE+'tmp');
	writeln(t,HOME+'php '+fileName);
	close(t);
	exec(SHELL, HOME+'temp.sh');
	erase(t);
End;

Procedure pause;
Begin
	write('Press enter to continue ...');
	readln;
End;

Procedure throwError(str:String);
Begin
	writeln;
	//textcolor(12);
	writeln('[ERROR] '+str);
	writeln;
	pause;
	//	execBusybox('sleep 1');
End;

Procedure initRuntimeFromZip(fileName:String);
Begin
	execBusybox('unzip -o '+fileName+' -d '+HOME);
End;

Procedure initCoreFromZip(fileName:String);
Begin
	execBusybox('unzip -o '+fileName+' -d '+WORKSPACE);
End;

Procedure writeDefaultWorkspace;
Var t: text;
Begin
	assign(t,HOME+'settings.conf');
	rewrite(t);
	writeln(t,'/sdcard/Genisys/');
	close(t);
End;

Procedure initWorkspace;
Var t: text;
Begin
	If Not fileExists(HOME+'settings.conf') Then
		Begin
			writeDefaultWorkspace;
		End;
	assign(t,HOME+'settings.conf');
	reset(t);
	readln(t,WORKSPACE);
	If Not fileExists(WORKSPACE) Then
		Begin
			throwError('Workspace not found, use /sdcard/Genisys/ as default');
			writeDefaultWorkspace;
			WORKSPACE := '/sdcard/Genisys/';
		End;
	close(t);
End;

Procedure saveWorkspace(dir:String);
Var t: text;
Begin
	If (dir[length(dir)] <> '/') Then dir := dir+'/';
	WORKSPACE := dir;
	assign(t,HOME+'settings.conf');
	rewrite(t);
	writeln(t,dir);
	close(t);
End;

Procedure initPhpConf(force:boolean = false);
Var t: text;
Begin
	If force Or Not fileExists(HOME+'php.ini') Then
		Begin
			assign(t,HOME+'php.ini');
			rewrite(t);
			writeln(t,'date.timezone=CDT');
			writeln(t,'short_open_tag=0');
			writeln(t,'asp_tags=0');
			writeln(t,'phar.readonly=0');
			writeln(t,'phar.require_hash=1');
			close(t);
		End;
End;

Procedure textcolor(int:longint);
Begin;
End;
//usage of CRT unit will cause format errors
{
procedure writeVersion;
var t:text;
begin
	assign(t,HOME+'ver.txt');rewrite(t);
	writeln(t,PROG_VER);
	close(t);
end;

procedure updateExecutable;
begi

procedure checkUpdate;
var
	t:text;
	ver:string;
begin
	if not fileExists(HOME+'ver.txt') then begin
		updateExeutable;
		exit;
	end else begin
		assign(t,HOME+'ver.txt');reset(t);
		readln(ver);
		if ver <> PROG_VRR then begin
			updateExecutable;
			exit;
		end;
	end;
end;
}

Procedure main;
Var opt: string;
Begin
	HOME := extractFilePath(paramStr(0));
	//Auto detect working home
	testPerm;
	initWorkspace;
	initPhpconf;
	//checkUpdate;
	//writeVersion;
	execBusybox('rm '+paramStr(0));
	execBusybox('mkdir '+WORKSPACE, false);
	execBusybox('mkdir '+WORKSPACE+'tmp', false);
	execBusybox('clear');
	textcolor(11);
	//AQUA
	writeln('Genisys Android '+PROG_VER);
	textcolor(13);
	//PURPLE
	writeln('Powered by iTX Technologies');
	writeln;
	writeln('Home: '+HOME);
	writeln('Workspace: '+WORKSPACE);
	writeln;
	textcolor(15);
	//WHITE
	writeln('a. Init Genisys Android from zips');
	//	writeln;
	textcolor(6);
	//YELLOW
	writeln('[NOTICE] Put php.zip and Genisys.zip into '+WORKSPACE);
	//	writeln;
	textcolor(15);
	writeln('b. Launch Genisys');
	//	writeln;
	writeln('c. Set workspace');
	//	writeln;
	writeln('d. Edit php.ini');
	writeln('[NOTICE] Please edit before launch Genisys');
	//	writeln;
	writeln('e. Rewrite php.ini');
	writeln;
	writeln('i. About Genisys Android');
	writeln;
	write('Select: ');

	readln(opt);
	If opt = 'a' Then
		Begin
			initRuntimeFromZip(WORKSPACE+'php.zip');
			initCoreFromZip(WORKSPACE+'Genisys.zip');
			writeln;
			writeln('Done!');
			writeln;
			pause;
			main;
			exit;
		End
	Else If opt = 'b' Then
		Begin
			If Not fileExists(HOME+'php') Then
				Begin
					throwError('Php runtime has not been installed !');
					main;
					exit;
				End;
			writeln;
			writeln('[NOTICE] Now loading ...');
			If fileExists(WORKSPACE+'Genisys.phar') Then execPhp(WORKSPACE, 'Genisys.phar')
			Else If fileExists(WORKSPACE+'src/pocketmine/PocketMine.php') Then execPhp(WORKSPACE, 'src/pocketmine/PocketMine.php')
			Else throwError('Genisys has not been installed !');
			writeln;
			pause;
			main;
			exit;
		End
	Else If opt = 'c' Then
		Begin
			write('Please enter the full path of workspace ['+WORKSPACE+'] ');
			readln(WORKSPACE);
			If WORKSPACE = '' Then
				Begin
					writeln;
					writeln('[INFO] Workspace has not changed');
					writeln;
					pause;
					main;
					exit;
				End
			Else
				If Not fileExists(WORKSPACE) Then
					Begin
						throwError(WORKSPACE+' does not exist');
						writeln;
						pause;
						main;
						exit;
					End
			Else
				Begin
					saveWorkspace(WORKSPACE);
					writeln('[INFO] Workspace has changed to '+WORKSPACE);
					writeln;
					pause;
					main;
					exit;
				End;
		End
	Else If opt = 'd' Then
		Begin
			execBusybox('vi '+HOME+'php.ini');
			pause;
			main;
			exit;
		End
	Else If opt = 'i' Then
		Begin
			execBusybox('clear');
			writeln('Genisys Android');
			writeln('Version: '+PROG_VER);
			writeln('Github repo: https://github.com/iTXTech/Genisys-Android');
			writeln;
			writeln('This application itself is based on Terminal Emulator for Android by jackpal.');
			writeln('This program is made by PeratX.');
			writeln('Genisys is made by iTX Technologies.');
			writeln('Genisys is a server software for Minecraft: Pocket Edition, which is based on the great project "PocketMine-MP".');
			writeln;
			writeln('Author: PeratX');
			writeln('QQ: 1215714524');
			writeln('E-mail: 1215714524@qq.com');
			writeln;
			pause;
			main;
			exit;
		End
	Else If opt = 'e' Then
		Begin
			initPhpConf(true);
			writeln;
			writeln('Done');
			writeln;
			pause;
			main;
			exit;
		End
	Else
		Begin
			throwError('Option not found !');
			main;
			exit;
		End;
End;

Begin
	If paramcount = 0 Then main
	Else If paramstr(1) = '-v' Then writeln(PROG_VER);
End.
