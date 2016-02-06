{
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *
 * Author: PeratX
 * Genisys-Android Project
}

program Genisys_Android;

{$mode objfpc}
uses dos,sysutils;

const PROG_VER:string='v0.2.2 alpha';
const HOME:string='/data/data/org.itxtech.genisysandroid/files/';
//const HOME:string='/data/data/com.n0n3m4.droidpascal/files/';//Only for test
const SHELL:string='/system/bin/sh';

var WORKSPACE:string='/sdcard/Genisys/';

procedure execBusybox(cmd:string;needLine:boolean = true);
begin
	exec(HOME+'busybox', cmd);
	if needLine then writeln;
end;

procedure execPhp(homedir,fileName:string);
var t:text;
begin
	execBusybox('chmod 777 '+HOME+'php');
	//Set Perm
	assign(t,HOME+'temp.sh');rewrite(t);
	writeln(t,'cd '+WORKSPACE);
	writeln(t,'export TMPDIR='+WORKSPACE+'tmp');
	writeln(t,HOME+'php '+fileName);
	close(t);
	exec(SHELL, HOME+'temp.sh');
	erase(t);
end;

procedure throwError(str:string);
begin
	writeln;
	//textcolor(12);
	writeln('[ERROR] '+str);
	execBusybox('sleep 1');
end;

procedure initRuntimeFromZip(fileName:string);
begin
	execBusybox('unzip -o '+fileName+' -d '+HOME);
end;

procedure initCoreFromZip(fileName:string);
begin
	execBusybox('unzip -o '+fileName+' -d '+WORKSPACE);
end;

procedure writeDefaultWorkspace;
var t:text;
begin
	assign(t,HOME+'settings.conf');rewrite(t);
	writeln(t,'/sdcard/Genisys/');
	close(t);
end;

procedure initWorkspace;
var t:text;
begin
	if not fileExists(HOME+'settings.conf') then begin
		writeDefaultWorkspace;
	end;
	assign(t,HOME+'settings.conf');reset(t);
	readln(t,WORKSPACE);
	if not fileExists(WORKSPACE) then begin
		throwError('Workspace not found, use /sdcard/Genisys/ as default');
		 writeDefaultWorkspace;
		 WORKSPACE:='/sdcard/Genisys';
	end;
	close(t);
end;

procedure pause;
begin
	write('Press enter to continue ...');
	readln;
end;

procedure saveWorkspace(dir:string);
var t:text;
begin
	if (dir[length(dir)] <> '/') then dir:=dir+'/';
	WORKSPACE:=dir;
	assign(t,HOME+'settings.conf');rewrite(t);
	writeln(t,dir);
	close(t);
end;

procedure initPhpConf(force:boolean = false);
var t:text;
begin
	if force or not fileExists(HOME+'php.ini') then begin
	assign(t,HOME+'php.ini');rewrite(t);
	writeln(t,'date.timezone=CDT');
	writeln(t,'short_open_tag=0');
	writeln(t,'asp_tags=0');
	writeln(t,'phar.readonly=0');
	writeln(t,'phar.require_hash=1');
	close(t);
	end;
end;

procedure textcolor(int:longint);
begin;end;//usage of CRT unit will cause format errors

procedure writeVersion;
var t:text;
begin
	assign(t,HOME+'ver.txt');rewrite(t);
	writeln(t,PROG_VER);
	close(t);
end;
{
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
procedure main;
var opt:string;
begin
	initWorkspace;
	initPhpconf;
	//checkUpdate;
	//writeVersion;
	execBusybox('rm '+HOME+'executable');
	execBusybox('mkdir '+WORKSPACE, false);
	execBusybox('clear');
	textcolor(11);//AQUA
	writeln('Genisys Android '+PROG_VER);
	textcolor(13);//PURPLE
	writeln('Powered by iTX Technologies');
	writeln;
	writeln('Workspace: '+WORKSPACE);
	writeln;
	textcolor(15);//WHITE
	writeln('a. Init Genisys Android from zips');
//	writeln;
	textcolor(6);//YELLOW
	writeln('[NOTICE] Put php.zip and Genisys.zip into '+WORKSPACE);
//	writeln;
	textcolor(15);
	writeln('b. Launch Genisys');
//	writeln;
	writeln('c. Set workspace');
//	writeln;
	writeln('d. Edit php.ini');
//	writeln;
	writeln('e. Rewrite php.ini');
	writeln;
	writeln('i. About Genisys Android');
	writeln;
	write('Select: ');

	readln(opt);
	if opt = 'a' then begin
		initRuntimeFromZip(WORKSPACE+'php.zip');
		initCoreFromZip(WORKSPACE+'Genisys.zip');
		writeln;
		writeln('Done!');
		writeln;
		pause;
		main;
		exit;
	end else if opt = 'b' then begin
		if not fileExists(HOME+'php') then begin
			throwError('Php runtime has not been installed !');
			main;
			exit;
		end;
		writeln;
		writeln('[NOTICE] Now loading ...');
		if fileExists(WORKSPACE+'Genisys.phar') then execPhp(WORKSPACE, 'Genisys.phar')
		else if fileExists(WORKSPACE+'src/pocketmine/PocketMine.php') then execPhp(WORKSPACE, 'src/pocketmine/PocketMine.php')
		else throwError('Genisys has not been installed !');
		writeln;
		pause;
		main;
		exit;
	end else if opt = 'c' then begin
		write('Please enter the full path of workspace ['+WORKSPACE+'] ');
		readln(WORKSPACE);
		if not fileExists(WORKSPACE) then begin
			throwError(WORKSPACE+' does not exist');
			writeln;
			pause;
			main;
			exit;
		end else begin
			saveWorkspace(WORKSPACE);
			writeln('[INFO] Workspace has changed to '+WORKSPACE);
			writeln;
			pause;
			main;
			exit;
		end;
	end else if opt = 'd' then begin
		execBusybox('vi '+HOME+'php.ini');
		main;
		exit;
	end else if opt = 'i' then begin
		execBusybox('clear');
		writeln('Genisys Android');
		writeln('Version: '+PROG_VER);
		writeln('Github repo: https://github.com/iTXTech/Genisys-Android');
		writeln;
		writeln('Author: PeratX');
		writeln('QQ: 1215714524');
		writeln('E-mail: 1215714524@qq.com');
		writeln;
		pause;
		main;
		exit;
	end else if opt = 'e' then begin
		initPhpConf(true);
		writeln;
		writeln('Done');
		writeln;
		pause;
		main;
		exit;
	end else begin
		throwError('Option not found !');
		main;
		exit;
	end;
end;
begin
	if paramcount = 0 then main
	else if paramstr(1) = '-v' then writeln(PROG_VER);
end.