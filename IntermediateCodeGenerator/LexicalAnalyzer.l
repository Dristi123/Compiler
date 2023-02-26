
%option noyywrap
%x characterstate
%x mulcomm
%x singcomm
%x string
%{
#include "symboltable.h"
#include "y.tab.h"
#include<stdio.h>
#include<iostream>
using namespace std;
extern SymbolTable st(7);
extern int line_count=1;
extern int err=0;
string logstring="";
string j="";
string mainstring="";
string k="";
string commentstring="";
string l="";
int temp;
extern FILE *logout;
extern FILE *errorout;
//extern FILE *logout;
char getone(char *str) {
    if(str[0]=='\\' && str[1]=='n') return '\n';
    else if (str[0]=='\\' && str[1]=='t') return '\t';
    else if (str[0]=='\\' && str[1]=='\\') return '\\';
    else if (str[0]=='\\' && str[1]=='\'') return '\'';
    else if (str[0]=='\\' && str[1]=='\"') return '\"';
    else if (str[0]=='\\' && str[1]=='a') return '\a';
    else if (str[0]=='\\' && str[1]=='f') return '\f';
    else if (str[0]=='\\' && str[1]=='r') return '\r';
    else if (str[0]=='\\' && str[1]=='b') return '\b';
    else if (str[0]=='\\' && str[1]=='v') return '\v';
    else if (str[0]=='\\' && str[1]=='0') return '\n';
    else return str[1];
}
void putchar(char *str){
    /*string temp="";
    temp.push_back('\'');
    temp.push_back(str[0]);
    if(str[1]!='\0')temp.push_back(str[1]);
    temp.push_back('\'');
    const char *temp2=temp.c_str();  
    //fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found ",line_count,temp2);
    //if(str[1]!='\0')fprintf(logout,"--> <CONST_CHAR,%c> ",getone(str));
    //else fprintf(logout,"--> <CONST_CHAR,%c> ",str[0]);
    //fprintf(logout,"\n");
    
    if(st.Insert(temp,"CONST_CHAR"))
    {//st.printall(logout); }
    else {
        //fprintf(logout,"%s already exits in current scopetable\n",temp2);
        //fprintf(logout,"\n");
    }*/
}

%}

Letter [a-zA-z]
Digit [0-9]
Alphanumeric [a-zA-Z0-9]
NEWLINE ((\r)?(\n))
WHITESPACE [ \t\f\r\v]+
%%
{NEWLINE} {line_count++;
          }
{WHITESPACE} {}
"if" {
    //fprintf(tokenout,"<IF> ");
	//fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    return IF;
    }

"else" {
    //fprintf(tokenout,"<ELSE> ");
	//fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    return ELSE;
    }

"for" {
    //fprintf(tokenout,"<FOR> ");
	//fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    return FOR;
    }

"while" {
    //fprintf(tokenout,"<WHILE> ");
	//fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    return WHILE;
    }
"printf" {
    return PRINTLN;
}
"println" {
    return PRINTLN;
}

"do" {
    //fprintf(tokenout,"<DO> ");
	//fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    }

"break" {  
    //fprintf(tokenout,"<BREAK> ");
	//fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    }

"int" {
    //fprintf(tokenout,"<INT> ");
	//fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    SymbolInfo *s=new SymbolInfo(yytext,"INT");
    yylval.si=s;
    return INT;
    }

"char" {
    //fprintf(tokenout,"<CHAR> ");
	//fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    }

"float" {
    //fprintf(tokenout,"<FLOAT> ");
	//fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    SymbolInfo *s=new SymbolInfo(yytext,"FLOAT");
    yylval.si=s;
    return FLOAT;
    }

"double" {
    //fprintf(tokenout,"<DOUBLE> ");
	//fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    }

"void" {
    //fprintf(tokenout,"<VOID> ");
	//fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    SymbolInfo *s=new SymbolInfo(yytext,"VOID");
    yylval.si=s;
    return VOID;
    }

"return" {
    //fprintf(tokenout,"<RETURN> ");
	//fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    return RETURN;
    }

"switch" {
    //fprintf(tokenout,"<SWITCH> ");
	//fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    }

"case" {
    //fprintf(tokenout,"<CASE> ");
	//fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    }

"default" {
    //fprintf(tokenout,"<DEFAULT> ");
	//fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    }

"continue" {
    //fprintf(tokenout,"<CONTINUE> ");
	//fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    }

{Digit}+  {
    
    /*fprintf(tokenout,"<CONST_INT,%s> ",yytext);
	fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
    fprintf(logout,"\n");
    if(st.Insert(yytext,"CONST_INT")){st.printall(logout);}
    else {
        fprintf(logout,"%s already exits in current scopetable\n",yytext);
        fprintf(logout,"\n");
    }*/
    SymbolInfo *s=new SymbolInfo(yytext,"CONST_INT");
    yylval.si=s;
    return CONST_INT;
}


{Digit}*((\.{Digit}+)?([Ee][+-]?{Digit}+)?){1} {  
    /*fprintf(tokenout,"<CONST_FLOAT,%s> ",yytext);
	fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
    fprintf(logout,"\n");
    if(st.Insert(yytext,"CONST_FLOAT")){ st.printall(logout);}
    else {
        fprintf(logout,"%s already exits in current scopetable\n",yytext);
        fprintf(logout,"\n");
    }*/
    SymbolInfo *s=new SymbolInfo(yytext,"CONST_FLOAT");
    yylval.si=s;
    return CONST_FLOAT;
}



\'  { 
    BEGIN characterstate;
    }
<characterstate>\\[tnafrv\\\'\"b0](\') {
    /*char temparr[3];
    strncpy(temparr,yytext,2);
    temparr[2]='\0';
    fprintf(tokenout,"<CONST_CHAR,%c> ",getone(temparr));	
    putchar(temparr);
    
    BEGIN INITIAL;*/
    }
<characterstate>(\') {
    /*fprintf(logout,"Error at Line no %d: Empty Character constant error \'%s\n",line_count,yytext);
    fprintf(logout,"\n");
    error++;
    BEGIN INITIAL;*/
}
<characterstate>[^\r\n\']{2,}(\') {
    /*fprintf(logout,"Error at Line no %d: Multi character constant error \'%s\n",line_count,yytext);
    fprintf(logout,"\n");
    error++;
    BEGIN INITIAL;*/
    }

<characterstate>[^\'\r\n]*((\r)?(\n)) {
    /*fprintf(logout,"Error at Line no %d: Unterminated Character \'%s",line_count,yytext);
    fprintf(logout,"\n");
    error++;
    line_count++;
    BEGIN INITIAL;*/
}
<characterstate>(\\\')[^\'\r\n]*((\r)?(\n)) {
    /*fprintf(logout,"Error at Line no %d: Unterminated Character \'%s",line_count,yytext);
    fprintf(logout,"\n");
    error++;
    line_count++;
    BEGIN INITIAL;*/
}

<characterstate>(.)(\') {
    /*char temparr[3];
    strncpy(temparr,yytext,1);
    temparr[1]='\0';
    fprintf(tokenout,"<CONST_CHAR,%c> ",yytext[0]);	
    putchar(temparr);
    BEGIN INITIAL;*/
    }

[+-] {
    //fprintf(tokenout,"<ADDOP,%s> ",yytext);
    //fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    SymbolInfo *s=new SymbolInfo(yytext,"ADDOP");
    yylval.si=s;
    return ADDOP;
    }
"*"|"/"|"%" {
    //fprintf(tokenout,"<MULOP,%s> ",yytext);
    //fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    SymbolInfo *s=new SymbolInfo(yytext,"MULOP");
    yylval.si=s;
    return MULOP;
    }

[+]{2} {
    //fprintf(tokenout,"<INCOP,%s>",yytext);
    //fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    return INCOP;
    }
[-]{2} {
    return DECOP;
}

"<"|"<="|">"|">="|"=="|"!=" {
    //fprintf(tokenout,"<RELOP,%s> ",yytext);
    //fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    SymbolInfo *s=new SymbolInfo(yytext,"RELOP");
    yylval.si=s;
    return RELOP;
    }

[=] {
    //fprintf(tokenout,"<ASSIGNOP,%s> ",yytext);
    //fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    return ASSIGNOP;
    }

"&&"|"||" {
    //fprintf(tokenout,"<LOGICOP,%s> ",yytext);
    //fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    SymbolInfo *s=new SymbolInfo(yytext,"LOGICOP");
    yylval.si=s;
    return LOGICOP;
    }

"!" {
    //fprintf(tokenout,"<NOT,%s> ",yytext);
    //fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    return NOT;
    }

[(] {
    //fprintf(tokenout,"<LPAREN,%s> ",yytext);
    //fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    return LPAREN;
    }

[)] {
    //fprintf(tokenout,"<RPAREN,%s> ",yytext);
    //fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
    //fprintf(logout,"\n");
    return RPAREN;
    }

[{] {
    
    return LCURL;
    }
[}] {
   /* st.Exit();
    fprintf(tokenout,"<RCURL,%s> ",yytext);
    fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
    fprintf(logout,"\n");*/
    return RCURL;
    }
"[" {
    /*fprintf(tokenout,"<LTHIRD,%s> ",yytext);
    fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
    fprintf(logout,"\n");*/
    return LTHIRD;
    }

"]" {
    /*fprintf(tokenout,"<RTHIRD,%s> ",yytext);
    fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
    fprintf(logout,"\n");*/
    return RTHIRD;
    }

"," {
    /*fprintf(tokenout,"<COMMA,%s> ",yytext);
    fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
    fprintf(logout,"\n");*/
    return COMMA;
    }

";" {  
    /*fprintf(tokenout,"<SEMICOLON,%s> ",yytext);
    fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
    fprintf(logout,"\n");*/
    return SEMICOLON;
    }
 
([a-zA-Z]|"_")({Alphanumeric}|"_")* {
    /*fprintf(tokenout,"<ID,%s> ",yytext);
    fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
    fprintf(logout,"\n");
    if(st.Insert(yytext,"ID")){st.printall(logout);}
    else {
            fprintf(logout,"%s already exits in current scopetable\n",yytext);
            fprintf(logout,"\n");
        }*/
    SymbolInfo *s=new SymbolInfo(yytext,"ID");
    yylval.si=s;
    return ID;
    }
({Digit}+([a-zA-Z]|"_")*)+{Digit}* {
    /*fprintf(logout,"Error at Line no %d: Invalid prefix on ID or invalid suffix on Number %s \n",line_count,yytext);
    fprintf(logout,"\n");
    error++;*/
    fprintf(logout,"Error at line no %d: Invalid prefix on ID or invalid suffix on Number %s\n\n",line_count,yytext);
	fprintf(errorout,"Error at line no %d: Invalid prefix on ID or invalid suffix on Number %s\n\n",line_count,yytext);
    err++;
    SymbolInfo *s=new SymbolInfo(yytext,"ID");
    yylval.si=s;
    return ID;
}

\" { 
    
    /*j=yytext;
    logstring=logstring+j;
    mainstring=mainstring+j;
    temp=line_count;
    BEGIN string;*/
    }

<string>\" {
    /*fprintf(tokenout,"<STRING,");
    fprintf(tokenout,"%s\"> ",logstring.c_str());
    fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s\" found --><STRING,",temp,mainstring.c_str());
    j=yytext;
    logstring=logstring+j;
    fprintf(logout,"%s>\n",logstring.c_str());
    fprintf(logout,"\n");
    logstring="";
    mainstring="";
    BEGIN INITIAL;*/
}
<string>\\[tnafrv\\\'\"b0] {
    /*k=yytext;
    mainstring=mainstring+k;
    j=getone(yytext);
    logstring=logstring+j;*/
}
<string>(\\.) {
    /*k=yytext;
    
    mainstring=mainstring+k;
    logstring=logstring+k;*/

    }   
<string>(\\((\r)?(\n))) {
    
   /* k=yytext;
    mainstring=mainstring+k;
    line_count++;*/
}
<string>((\r)?(\n)) {
    
    /*fprintf(logout,"Error at Line no %d: Unfinished String %s%s",temp,mainstring.c_str(),yytext);
    fprintf(logout,"\n");
    error++;
    line_count++;
    logstring="";
    mainstring="";
    BEGIN INITIAL;*/
}
<string>[\.?()]* {
    /*j=yytext;
    logstring=logstring+j;
    mainstring=mainstring+j;*/
}
<string>[^\"(\\.)(\\((\r)?(\n)))(((\r)?(\n)))]* { 
    
    /*j=yytext;
    logstring=logstring+j;
    mainstring=mainstring+j;*/
    }
"/*" {   
    /*temp=line_count;
    BEGIN mulcomm;
    l=yytext;
    commentstring=commentstring+l;*/
    }

<mulcomm>"*/" {
    /*fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s%s found.\n",temp,commentstring.c_str(),yytext);
    fprintf(logout,"\n");
    commentstring="";
    BEGIN INITIAL;*/
    }
<mulcomm>[?()]* {
    /*l=yytext;
    commentstring=commentstring+l;*/
}
<mulcomm>[^\*((\r)?(\n))]* {
    /*l=yytext;
    commentstring=commentstring+l;*/
    }
<mulcomm>"*" {
    /*l=yytext;
    commentstring=commentstring+l;*/
    }
<mulcomm>((\r)?(\n)) {
            /*l=yytext;
            commentstring=commentstring+l;
            line_count++;*/
            }
<mulcomm><<EOF>> {
    /*fprintf(logout,"Error at Line no %d: Unfinished Comment %s",temp,commentstring.c_str());
    fprintf(logout,"\n");
    error++;
    commentstring="";
    BEGIN INITIAL;*/
}
"//" {
    /*fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s",line_count,yytext);
    BEGIN singcomm;*/
    }
<singcomm>((\r)?(\n)) {
        /*line_count++;
        fprintf(logout," found\n");
        fprintf(logout,"\n");
        BEGIN INITIAL;*/
    }
<singcomm>[^(\\((\r)?(\n)))]* {
        //fprintf(logout,"%s",yytext);
    }
<singcomm>[\\?()]* {
    //fprintf(logout,"%s",yytext);
}
<singcomm>(\\((\r)?(\n)))  {
        //fprintf(logout,"%s",yytext);
        //line_count++;
    } 
(.) {
    //error++;
    //fprintf(logout,"Error at Line no %d: Unrecognized Character %s\n",line_count,yytext);
    //fprintf(logout,"\n");
    fprintf(logout,"Error at line no %d: Unrecognized Character %s\n\n",line_count,yytext);
	fprintf(errorout,"Error at line no %d: Unrecognized Character %s\n\n",line_count,yytext);
    err++;
    }
{Digit}*((\.{Digit}*)([Ee][+-]?{Digit}+)?)[a-zA-Z]* {
    //fprintf(logout,"Error at Line no %d: Ill formed Number %s \n",line_count,yytext);
    //fprintf(logout,"\n");
    fprintf(logout,"Error at line no %d: Ill formed Number  %s\n\n",line_count,yytext);
	fprintf(errorout,"Error at line no %d: Ill formed Number %s\n\n",line_count,yytext);
    err++;
    SymbolInfo *s=new SymbolInfo(yytext,"CONST_FLOAT");
    yylval.si=s;
    return CONST_FLOAT;
}
{Digit}*(\.{Digit}*)?([Ee][+-]?{Digit}*((\.)+{Digit}*)*)* {
    //fprintf(logout,"Error at Line no %d: Ill formed Number %s \n",line_count,yytext);
    //fprintf(logout,"\n");
    fprintf(logout,"Error at line no %d: Ill formed Number  %s\n\n",line_count,yytext);
	fprintf(errorout,"Error at line no %d: Ill formed Number %s\n\n",line_count,yytext);
    err++;
    SymbolInfo *s=new SymbolInfo(yytext,"CONST_FLOAT");
    yylval.si=s;
    return CONST_FLOAT;
}
{Digit}*((\.)+{Digit}*)*(([Ee][+-]?{Digit}*((\.)+{Digit}*)*)*)? {
    //fprintf(logout,"Error at Line no %d: Too many decimal points %s \n",line_count,yytext);
    //fprintf(logout,"\n");
    fprintf(logout,"Error at line no %d: Too many decimal points %s\n\n",line_count,yytext);
	fprintf(errorout,"Error at line no %d: Too many decimal points %s\n\n",line_count,yytext);
    err++;
    SymbolInfo *s=new SymbolInfo(yytext,"CONST_FLOAT");
    yylval.si=s;
    return CONST_FLOAT;
}
<<EOF>> {
    //st.printall(logout);
    //fprintf(logout,"Total Lines: %d\n",line_count);
    //fprintf(logout,"Total Errors:%d",error);
    return 0;
    }

%%

/*int main(int argc,char** argv) {
    if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
    FILE *fin=fopen(argv[1],"r");
    if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
    logout= fopen("1705029_log.txt","w");
    tokenout= fopen("1705029_token.txt","w");
    yyin=fin;
    yylineno=1;
    yylex();
    fclose(yyin);
    fclose(logout);
    fclose(tokenout);
    
    return 0;
}*/