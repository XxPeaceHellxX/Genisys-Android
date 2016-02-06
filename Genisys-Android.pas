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
const PROG_VER:string='v0.1.1 alpha';
const HOME:string='/data/data/org.itxtech.genisysandroid/files/';
const WORKSPACE:string='/sdcard/Genisys/';
const SHELL:string='/system/bin/sh';
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
procedure textcolor(int:longint);
begin;end;//usage of CRT unit will cause format errors
procedure main;
var opt:string;
begin
	execBusybox('mkdir '+WORKSPACE, false);
	execBusybox('clear');
	textcolor(11);//AQUA
	writeln('Genisys Android '+PROG_VER);
	textcolor(13);//PURPLE
	writeln('Powered by iTX Technologies');
	writeln;
	textcolor(15);//WHITE
	writeln('a. Init Genisys Android from zips');
	writeln;
	textcolor(6);//YELLOW
	writeln('[NOTICE] Put php.zip and Genisys.zip into /sdcard/Genisys');
	writeln;
	textcolor(15);
	writeln('b. Launch Genisys');
	writeln;
	writeln('Enter "a" or "b" ...');

	readln(opt);
	if opt = 'a' then begin
		initRuntimeFromZip(WORKSPACE+'php.zip');
		initCoreFromZip(WORKSPACE+'Genisys.zip');
		writeln;
		writeln('Done!');
		execBusybox('sleep 1');
		main;
	end else if opt = 'b' then begin
		if not fileExists(HOME+'php') then begin
			throwError('Php runtime has not been installed !');
			main;
		end;
		writeln;
		writeln('[NOTICE] Now loading ...');
		if fileExists(WORKSPACE+'Genisys.phar') then execPhp(WORKSPACE, 'Genisys.phar')
		else if fileExists(WORKSPACE+'src/pocketmine/PocketMine.php') then execPhp(WORKSPACE, 'src/pocketmine/PocketMine.php')
		else throwError('Genisys has not been installed !');
		execBusybox('sleep 2');
		main;
	end else begin
		throwError('Option not found !');
		main;
	end;
end;
begin
	main;
end.