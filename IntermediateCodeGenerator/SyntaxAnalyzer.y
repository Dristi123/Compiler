%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<bits/stdc++.h>
#include<vector>
#include "symboltable.h"


using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
string type="";
string un="";
string prog="";
extern int line_count;
extern int err;
extern FILE *logout=fopen("log.txt","w");;
extern FILE *errorout=fopen("error.txt","w");
FILE *asmout=fopen("code.asm","w");
FILE *optout=fopen("optimized_code.asm","w");
;

SymbolTable table(30);

vector<SymbolInfo*>dl;
vector<SymbolInfo*>to_be_inserted_dl;
vector<string>asm_variables;
vector<pair<string,string>> asm_arrays;
vector<string> current_arg_list;
vector<string>current_par_list;
vector<string> current_temp_list;
vector<pair<string,string>> pl;
vector<pair<string,string>> to_be_inserted_pl;
vector<pair<string,string>> al;
string func_name="";
string cid="";
int labelCount=0;
int tempCount=0;


char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}
string getarrname(const char *in) {
	string ret="";
	for(int i=0;in[i]!='\0';i++) {
		if(in[i]=='[') break;
		ret.push_back(in[i]);
	}
	return ret;
}
string inttostring(int a) {
	stringstream ss;
	ss << a;
	string myString = ss.str();
	return myString;
}

void yyerror(char *s)
{
	//write your code
	fprintf(logout,"Error at line %d: Syntax Error\n\n",line_count);
	fprintf(errorout,"Error at line %d: Syntax Error\n\n",line_count);
	err++;
	
}
void optimization(string code) {
	
	vector<string>opt_code;
	vector<string>to_be_written;
	vector<string> first_line;
	vector<string> second_line;
	string line;
    stringstream ss(code);

    while(getline(ss, line, '\n')) {

        if(!line.empty()) {
			if(line.substr(1,1)!=";")opt_code.push_back(line);
		}
    }
	
	for(int i=0;i<opt_code.size();) {
		if(opt_code[i].substr(1,3)=="MOV" && opt_code[i+1].substr(1,3)=="MOV") {
			string s;
			string d;
			int flag=0;
			string total=opt_code[i].substr(5,opt_code[i].length()-1);
			string total2=opt_code[i+1].substr(5,opt_code[i+1].length()-1);
			stringstream s1(total);
			stringstream s2(total2);
    		while(getline(s1, s, ',')) {

        		 first_line.push_back(s);
    		}
			
			while(getline(s2, d, ',')) {

        		 second_line.push_back(d);
    		}
			
			if(first_line[0]==second_line[1] && first_line[1]==second_line[0]) {
				flag=1;
					
			}
			first_line.clear();
			second_line.clear();
			fprintf(optout,"%s\n",opt_code[i].c_str());
			
			if(flag==1) i=i+2;
			else i=i+1;
		}
		else if(opt_code[i].substr(1,3)=="JMP") {
			
			int k=1;
			int flag=0;
			int flag1=0;
			vector<string> labels;
			
			string label=opt_code[i].substr(5,opt_code[i].length()-1);
			//cout<<"hereee"<<endl;
			//cout<<label<<endl;
			for(int j=0;j<i;j++) {
				if(opt_code[j].substr(0,opt_code[j].length()-1)==label) {
					flag=1;
					break;
				}
			}
			for(int j=0;j<opt_code.size();j++) {
				if(j==i) continue;
				if(opt_code[j].substr(1,2)=="JE"||opt_code[j].substr(1,2)=="JL"||opt_code[j].substr(1,2)=="JG"||opt_code[j].substr(1,2)=="JN"||opt_code[j].substr(1,2)=="JM") {
					
					string l=opt_code[j].substr(4,opt_code[j].length()-1);
					if(l[0]==' ') labels.push_back(l.erase(0,1));
					else labels.push_back(l);
					
				}
			}
			
			if(flag==0) {
			while((opt_code[i+k].substr(0,opt_code[i+k].length()-1)!=label)) {
				int p;
				for(p=0;p<labels.size();p++) {
				if(opt_code[i+k].substr(0,opt_code[i+k].length()-1)==labels[p]) {
					
					break;
				}
				}
				if(p!=labels.size()) {
					flag1=1;
					k=1;
					break;
				}
				k++;
				
			}
			
			
			
		}
		fprintf(optout,"%s\n",opt_code[i].c_str());	
		i=i+k;
		}
		else {
			//i=i+1;
			fprintf(optout,"%s\n",opt_code[i].c_str());
			i=i+1;
			
			
		}
		
	}
	
	fprintf(optout,"\nPRINTLN PROC\n\t");
	fprintf(optout,"PUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\tCMP AX,0\n\tJGE POS_\n\tNEG AX\n\tPUSH AX\n\tMOV DL,2DH \n\tMOV AH,2 \n\tINT 21H\n\tPOP AX\nPOS_:\n\tXOR CX,CX\n\tMOV BX,10\nDIVISION_:\n\tXOR DX,DX\n\tDIV BX\n\tPUSH DX\n\tADD CX,1\n\tCMP AX,0\n\tJNE DIVISION_\nPRINT_:\n\tCMP CX,0\n\tJE EXITPROC_\n\tPOP DX\n\tADD DX,30H\n\tMOV AH,2\n\tINT 21H\n\tSUB CX,1\n\tJMP PRINT_\nEXITPROC_:\n\tMOV DL, 10\n\tMOV AH, 02H\n\tINT 21H\n\tMOV DL, 13\n\tMOV AH, 02H\n\tINT 21h\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n\tPRINTLN ENDP\n\tEND MAIN\n");
}


%}

%union {
	int ival;
	SymbolInfo *si;
	
}
%token SEMICOLON COMMA LTHIRD RTHIRD ASSIGNOP RETURN LCURL RCURL INCOP DECOP LPAREN RPAREN WHILE PRINTLN FOR ELSE IF NOT
%token<si> INT ID FLOAT CONST_INT VOID ADDOP LOGICOP RELOP CONST_FLOAT MULOP
%type<si> unit var_declaration program func_declaration type_specifier variable expression factor unary_expression term simple_expression rel_expression logic_expression statement statements compound_statement func_definition expression_statement arguments argument_list

//%left 
//%right

%nonassoc LOW
%nonassoc ELSE
%%

start : program
	{
		fprintf(logout,"Line %d: start : program\n",line_count-1);
		//fprintf(logout,"%s",$1->getname().c_str());
		//fprintf(logout,"\n\n");
		//fprintf(logout,"SymbolTable: \n");
		table.printall(logout);
		fprintf(logout,"Total lines: %d\n",line_count-1);
		fprintf(logout,"Total errors: %d\n",err);
		string initasm=".MODEL SMALL\n\n.STACK 100H\n\n.DATA\n\n";
		if(err==0) {
			fprintf(asmout,"%s",initasm.c_str());
			for(int i=0;i<asm_variables.size();i++) {
				fprintf(asmout,"%s DW ?\n",asm_variables[i].c_str());
				initasm=initasm+asm_variables[i]+" DW ?\n";
			}
			fprintf(asmout,"\n\n");
			for(int i=0;i<asm_arrays.size();i++) {
				fprintf(asmout,"%s DW %s DUP(?)\n",asm_arrays[i].first.c_str(),asm_arrays[i].second.c_str());
				initasm=initasm+asm_arrays[i].first+" DW "+asm_arrays[i].second+" DUP(?)\n";
			}

		fprintf(asmout,"\n\n");
		
		fprintf(asmout,"%s\n\t",$1->getcode().c_str());
		initasm=initasm+$1->getcode();
		fprintf(asmout,"\nPRINTLN PROC\n\t");
		fprintf(asmout,"PUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\tCMP AX,0\n\tJGE POS_\n\tNEG AX\n\tPUSH AX\n\tMOV DL,2DH \n\tMOV AH,2 \n\tINT 21H\n\tPOP AX\nPOS_:\n\tXOR CX,CX\n\tMOV BX,10\nDIVISION_:\n\tXOR DX,DX\n\tDIV BX\n\tPUSH DX\n\tADD CX,1\n\tCMP AX,0\n\tJNE DIVISION_\nPRINT_:\n\tCMP CX,0\n\tJE EXITPROC_\n\tPOP DX\n\tADD DX,30H\n\tMOV AH,2\n\tINT 21H\n\tSUB CX,1\n\tJMP PRINT_\nEXITPROC_:\n\tMOV DL, 10\n\tMOV AH, 02H\n\tINT 21H\n\tMOV DL, 13\n\tMOV AH, 02H\n\tINT 21h\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n\tPRINTLN ENDP\n\tEND MAIN\n");
		//write your code in this block in all the similar blocks below
		//string habijabi="\tJMP L1\n\tADD FT,UI\n\tOKKKKK\nL1:\n\thereeee";
		
		optimization(initasm);
	}
	}
	;


program : program unit 
		{
			fprintf(logout,"Line %d: program : program unit\n\n",line_count);
			fprintf(logout,"%s",$1->getname().c_str());
			fprintf(logout,"%s",$2->getname().c_str());
			fprintf(logout,"\n\n");
			$$=new SymbolInfo($1->getname()+$2->getname(),"PROG");
			$$->setcode($1->getcode()+$2->getcode());
		}

		| 	unit  
		{
			//cout<<"program"<<endl;
			fprintf(logout,"Line %d: program : unit\n\n",line_count);
			fprintf(logout,"%s",$1->getname().c_str());
			fprintf(logout,"\n\n");
			$$=new SymbolInfo($1->getname(),"PROG");
			$$->setcode($1->getcode());
		}

		;
	

unit : var_declaration 
	{
	$$=new SymbolInfo($1->getname()+"\n","UNIT");
	fprintf(logout,"Line %d: unit : var_declaration\n\n",line_count);
	fprintf(logout,"%s",$1->getname().c_str());
	fprintf(logout,"\n\n\n");
	}

	|func_declaration 
	{
	$$=new SymbolInfo($1->getname()+"\n","UNIT");
	fprintf(logout,"Line %d: unit : func_declaration\n\n",line_count);
	fprintf(logout,"%s",$1->getname().c_str());
	fprintf(logout,"\n\n\n");
	}

	|func_definition 
	{
	$$=new SymbolInfo($1->getname()+"\n","UNIT");
	fprintf(logout,"Line %d: unit : func_definition\n\n",line_count);
	fprintf(logout,"%s",$1->getname().c_str());
	fprintf(logout,"\n\n\n");
	$$->setcode($1->getcode());
	}

    ;


var_declaration : type_specifier declaration_list SEMICOLON 
				{
					fprintf(logout,"Line %d: var_declaration : type_specifier declaration_list SEMICOLON\n\n",line_count);
					un=un+$1->getname()+" ";
					for(int i=0;i<dl.size()-1;i++) {
					un=un+dl[i]->getname()+",";
					}
					un=un+dl[dl.size()-1]->getname()+";";
					$$=new SymbolInfo(un,"VARDEC");
					SymbolInfo *varin=NULL;
					if($1->getname()=="void") {
						fprintf(logout,"Error at line %d: Variable type cannot be void\n\n",line_count);
						fprintf(errorout,"Error at line %d: Variable type cannot be void\n\n",line_count);
						err++;
					}
					else {
						for(int i=0;i<to_be_inserted_dl.size();i++) {
							if(to_be_inserted_dl[i]->gettype()=="ARRAY") {
							string t=getarrname(to_be_inserted_dl[i]->getname().c_str());
							varin=new SymbolInfo(t,"ID");
							varin->setvarsize(to_be_inserted_dl[i]->getvarsize());
							varin->setvarid(to_be_inserted_dl[i]->getvarid());
							asm_arrays.push_back(std::make_pair(to_be_inserted_dl[i]->getvarid(),inttostring(to_be_inserted_dl[i]->getvarsize())));
								
						}
						else {
							varin=new SymbolInfo(to_be_inserted_dl[i]->getname(),"ID");
							varin->setvarid(to_be_inserted_dl[i]->getvarid());
							asm_variables.push_back(to_be_inserted_dl[i]->getvarid());
							current_temp_list.push_back(to_be_inserted_dl[i]->getvarid());

						}
						varin->setvartype($1->getname());
						//cout<<varin->getname()<<varin->getvartype()<<endl;
						table.getcurrent()->Insert(varin);
					   }
				    }
					fprintf(logout,"%s\n\n",un.c_str());
					dl.clear();
					to_be_inserted_dl.clear();
					type="";
					un="";
				}

				| type_specifier error declaration_list SEMICOLON 
				{
					un=un+$1->getname()+" ";
					for(int i=0;i<dl.size()-1;i++) {
					un=un+dl[i]->getname()+",";
					}
					un=un+dl[dl.size()-1]->getname()+";";
					$$=new SymbolInfo(un,"VARDEC");
					SymbolInfo *varin=NULL;
					if($1->getname()=="void") {
						fprintf(logout,"Error at line %d: Variable declared void\n\n",line_count);
						fprintf(errorout,"Error at line %d: Variable declared void\n\n",line_count);
						err++;
					}
					else {
						for(int i=0;i<to_be_inserted_dl.size();i++) {
							if(to_be_inserted_dl[i]->gettype()=="ARRAY") {
							string t=getarrname(to_be_inserted_dl[i]->getname().c_str());
							varin=new SymbolInfo(t,"ID");
							varin->setvarsize(dl[i]->getvarsize());
						
						}
						else {
							varin=new SymbolInfo(to_be_inserted_dl[i]->getname(),"ID");
						}
						varin->setvartype($1->getname());
						//cout<<varin->getname()<<varin->getvartype()<<endl;
						table.getcurrent()->Insert(varin);
						}
					}
					dl.clear();
					to_be_inserted_dl.clear();
					type="";
					un="";
				}
				
 		 		;


func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
 			{
				fprintf(logout,"Line %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",line_count);
				SymbolInfo *temp=table.Lookup($2->getname());
				if(temp==NULL) {
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					funin->setvartype("DEC");
					for(int i=0;i<pl.size();i++) {
						funin->setparam(pl[i].first,pl[i].second);
					}
					table.getcurrent()->Insert(funin);
				}
				else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
					}
				
				un=un+$1->getname()+" "+$2->getname()+"(";
				for(int i=0;i<pl.size()-1;i++) {
					un=un+pl[i].first+" "+pl[i].second+",";
					}
					un=un+pl[pl.size()-1].first+" "+pl[pl.size()-1].second+");";
					fprintf(logout,"%s\n\n\n",un.c_str());
					$$=new SymbolInfo(un,"FUNCDEC");
					
					pl.clear();
					to_be_inserted_pl.clear();
					un="";
			}


				| type_specifier ID LPAREN RPAREN SEMICOLON 
			{
					fprintf(logout,"Line %d: func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n",line_count);
					SymbolInfo *temp=table.Lookup($2->getname());
					if(temp==NULL) {
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					funin->setvartype("DEC");
					funin->setparam("empty","empty");
					table.getcurrent()->Insert(funin);
					}
					else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
					}
					un=un+$1->getname()+" "+$2->getname()+"();";	
					fprintf(logout,"%s\n\n\n",un.c_str());
					$$=new SymbolInfo(un,"FUNCDEC");
					pl.clear();
					to_be_inserted_pl.clear();
					un="";
			}

			| type_specifier ID LPAREN parameter_list error RPAREN SEMICOLON 
			{
				SymbolInfo *temp=table.Lookup($2->getname());
				if(temp==NULL) {
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					funin->setvartype("DEC");
					for(int i=0;i<pl.size();i++) {
						funin->setparam(pl[i].first,pl[i].second);
					}
					table.getcurrent()->Insert(funin);
				}
				else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
					}
				
				un=un+$1->getname()+" "+$2->getname()+"(";
				for(int i=0;i<pl.size()-1;i++) {
					un=un+pl[i].first+" "+pl[i].second+",";
					}
					un=un+pl[pl.size()-1].first+" "+pl[pl.size()-1].second+");";
					
					$$=new SymbolInfo(un,"FUNCDEC");
					
					pl.clear();
					to_be_inserted_pl.clear();
					un="";
			}

			| type_specifier ID LPAREN error parameter_list  RPAREN SEMICOLON
			{
				SymbolInfo *temp=table.Lookup($2->getname());
				if(temp==NULL) {
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					funin->setvartype("DEC");
					for(int i=0;i<pl.size();i++) {
						funin->setparam(pl[i].first,pl[i].second);
					}
					table.getcurrent()->Insert(funin);
				}
				else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
					}
				
				un=un+$1->getname()+" "+$2->getname()+"(";
				for(int i=0;i<pl.size()-1;i++) {
					un=un+pl[i].first+" "+pl[i].second+",";
					}
					un=un+pl[pl.size()-1].first+" "+pl[pl.size()-1].second+");";
					
					$$=new SymbolInfo(un,"FUNCDEC");
					
					pl.clear();
					to_be_inserted_pl.clear();
					un="";
			}

			| type_specifier ID LPAREN parameter_list  RPAREN error 
			{
				SymbolInfo *temp=table.Lookup($2->getname());
				if(temp==NULL) {
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					funin->setvartype("DEC");
					for(int i=0;i<pl.size();i++) {
						funin->setparam(pl[i].first,pl[i].second);
					}
					table.getcurrent()->Insert(funin);
				}
				else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
					}
				
				un=un+$1->getname()+" "+$2->getname()+"(";
				for(int i=0;i<pl.size()-1;i++) {
					un=un+pl[i].first+" "+pl[i].second+",";
					}
					un=un+pl[pl.size()-1].first+" "+pl[pl.size()-1].second+");";
					$$=new SymbolInfo(un,"FUNCDEC");
					pl.clear();
					to_be_inserted_pl.clear();
					un="";
			}
			| type_specifier ID LPAREN RPAREN error
			{
					SymbolInfo *temp=table.Lookup($2->getname());
					if(temp==NULL) {
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					funin->setvartype("DEC");
					funin->setparam("empty","empty");
					table.getcurrent()->Insert(funin);
					}
					else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
					}
					un=un+$1->getname()+" "+$2->getname()+"();";	
					
					$$=new SymbolInfo(un,"FUNCDEC");
					pl.clear();
					to_be_inserted_pl.clear();
					un="";
			}

			| type_specifier ID LPAREN error RPAREN  SEMICOLON
			{
					SymbolInfo *temp=table.Lookup($2->getname());
					if(temp==NULL) {
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					funin->setvartype("DEC");
					funin->setparam("empty","empty");
					table.getcurrent()->Insert(funin);
					}
					else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
					}
					un=un+$1->getname()+" "+$2->getname()+"();";	
					
					$$=new SymbolInfo(un,"FUNCDEC");
					pl.clear();
					to_be_inserted_pl.clear();
					un="";
			}

			;
 		 

type_specifier	: INT 
				{
					//cout<<"Type specifier  :INT"<<endl;
					fprintf(logout,"Line %d: type_specifier : INT\n\n",line_count);
					fprintf(logout,"%s",$1->getname().c_str());
					fprintf(logout,"\n\n");
					$$=new SymbolInfo("int","TYPE");

				}

				| FLOAT
				{
					//cout<<"Type specifier  :FLOAT"<<endl;
					fprintf(logout,"Line %d: type_specifier : FLOAT\n\n",line_count);
					fprintf(logout,"%s",$1->getname().c_str());
					fprintf(logout,"\n\n");
					$$=new SymbolInfo("float","TYPE");

				}

				| VOID
				{
					//cout<<"Type specifier  :VOID"<<endl;
					fprintf(logout,"Line %d: type_specifier : VOID\n\n",line_count);
					fprintf(logout,"%s",$1->getname().c_str());
					fprintf(logout,"\n\n");
					$$=new SymbolInfo("void","TYPE");
				}

 				;


func_definition : type_specifier ID LPAREN parameter_list RPAREN
				{
					//cout<<"ashol taa"<<endl;
					int flag=0;
					int alreadyerror=0;
					SymbolInfo *temp=table.Lookup($2->getname());
					SymbolInfo *final=NULL;
					if(temp!=NULL) {
						flag=2;
						if(temp->getrettype()!="" && temp->getvartype()=="DEC") {
							flag=1;
							final=temp;
					}
					else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
						alreadyerror=1;
					}
					}
					if(flag==0){
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					for(int i=0;i<pl.size();i++) {
						funin->setparam(pl[i].first,pl[i].second);
					}
					table.getcurrent()->Insert(funin);
					}
					else if(flag==1) {
						if(final->getrettype()!=$1->getname()) {
							fprintf(logout,"Error at line %d: Return type mismatch with function declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Return type mismatch with function declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
							alreadyerror=1;
						}
						else if(final->getparamlist().size()==1 && final->getparamlist()[0].first=="empty" && final->getparamlist()[0].second=="empty") {
							if(pl.size()!=0) {
							fprintf(logout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
							alreadyerror=1;
							}
						}
						else if(final->getparamlist().size()==1 && final->getparamlist()[0].first=="empty" && final->getparamlist()[0].second=="empty") {
							if(pl.size()!=0) {
							fprintf(logout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
							alreadyerror=1;
							}
						}
						
						else if(final->getparamlist().size()!=pl.size()) {
							fprintf(logout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
							alreadyerror=1;

						}
						else {
							int fl=0;
							int num;
							for(int i=0;i<pl.size();i++) {
								if(pl[i].first!=final->getparamlist()[i].first) {
									fl=1;
									num=i;
									break;

								}
							}
							if(fl==1) {
							fprintf(logout,"Error at line %d: %dth parameter's type does not match with declaration in function %s\n\n",line_count,num+1,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: %dth parameter's type does not match with declaration in function %s\n\n",line_count,num+1,$2->getname().c_str());
							err++;
							alreadyerror=1;
							}
						}
						final->setvartype("");
					}
					if(alreadyerror==0) {
						int fl=0;
						int num;
						for(int i=0;i<pl.size();i++) {
							if(pl[i].first!="void" && pl[i].second=="") {
								fl=1;
								num=i;
								break;
							}
						}
						if(fl==1) {
							fprintf(logout,"Error at line %d: %dth parameter's name not given in function definition of %s\n\n",line_count,num+1,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: %dth parameter's name not given in function definition of %s\n\n",line_count,num+1,$2->getname().c_str());
							err++;
						}
					}
					func_name=$2->getname();
					

					} compound_statement {
					fprintf(logout,"Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",line_count);
					un=un+$1->getname()+" "+$2->getname()+"(";
					for(int i=0;i<pl.size()-1;i++) {
					un=un+pl[i].first+" "+pl[i].second+",";
					}
					

					un=un+pl[pl.size()-1].first+" "+pl[pl.size()-1].second+")"+$7->getname();
					fprintf(logout,"%s\n\n\n",un.c_str());
					un=un+"\n";
					$$=new SymbolInfo(un,"FUNCDEF");
					
					
					//$$->setcode()
					pl.clear();
					un="";
					
					if($2->getname()=="main") {
						string code="";
						code=code+"\nMAIN PROC\n\t"+"MOV AX, @DATA\n\tMOV DS, AX\n\t"+$7->getcode()+"\n\tMOV AH, 4CH\n\tINT 21H\n\tMAIN ENDP\n";
						$$->setcode(code);
					}
					else {
						string code="";
						int x=6+(4*current_par_list.size())+(2*current_temp_list.size())+2-(2*current_par_list.size()-2);
						//cout<<current_par_list.size()<<endl;
						//cout<<current_temp_list.size()<<endl;
						string return_label=func_name+"ret_";
						code=code+"\n"+$2->getname()+" PROC\n\t"+"PUSH AX\n\tPUSH CX\n\tPUSH DX\n\t";
						for(int i=0;i<current_par_list.size();i++) {
							code=code+"PUSH "+current_par_list[i]+"\n\t";
						}
						for(int i=0;i<current_temp_list.size();i++) {
							code=code + "PUSH "+current_temp_list[i]+"\n\t";
						}
						code=code+"PUSH BP\n\t"+"MOV BP,SP\n\t";
						for(int i=0;i<current_par_list.size();i++) {
							code=code+"MOV AX,[BP+"+inttostring(x)+"]\n\tMOV "+current_par_list[i]+",AX\n\t";
							x=x+2;
						}
						code=code+$7->getcode()+"\n"+return_label+":\n\t";
						code=code+"POP BP\n\t";
						for(int i=current_temp_list.size()-1;i>=0;i--) {
							code=code + "POP "+current_temp_list[i]+"\n\t";
						}
						for(int i=current_par_list.size()-1;i>=0;i--) {
							code=code + "POP "+current_par_list[i]+"\n\t";
						}
						code=code+"POP DX\n\tPOP CX\n\tPOP AX\n\t";
						code=code+"RET "+inttostring(2*current_par_list.size())+"\n\t"+$2->getname()+" ENDP\n\t";
						
						$$->setcode(code);
						
						
					}
					//cout<<$$->getcode()<<endl;
					//cout<<current_par_list.size()<<endl;
					current_par_list.clear();
					current_temp_list.clear();
					
					func_name="";
					
				}

					| type_specifier ID LPAREN RPAREN 
				{
					
					int flag=0;
					func_name=$2->getname();
					SymbolInfo *temp=table.Lookup($2->getname());
					SymbolInfo *final=NULL;
					if(temp!=NULL) {
						flag=2;
						if(temp->getrettype()!="" && temp->getvartype()=="DEC") {
							flag=1;
							final=temp;
						}
						else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
					}
					}
					if(flag==0) {
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					funin->setparam("empty","empty");
					table.getcurrent()->Insert(funin);
					
					} 
					else if(flag==1) {
						if(final->getrettype()!=$1->getname()) {
							fprintf(logout,"Error at line %d: Return type mismatch with function declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Return type mismatch with function declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
						}
						else if(final->getparamlist().size()!=1 && final->getparamlist()[0].first!="empty" && final->getparamlist()[0].second!="empty") {
							fprintf(logout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
							//alreadyerror=1;
						}
						
						final->setvartype("");
						//func_name=$2->getname();
						
					}
					//a=$2->getname();
					}compound_statement {
					
					fprintf(logout,"Line %d: func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",line_count);
					un=un+$1->getname()+" "+$2->getname()+"()"+$6->getname();	
					fprintf(logout,"%s\n\n\n",un.c_str());
					un=un+"\n";
					$$=new SymbolInfo(un,"FUNCDEF");
					
					$$->setcode($6->getcode());
					pl.clear();
					un="";
					if($2->getname()=="main") {
						string code="";
						code=code+"\nMAIN PROC\n\t"+"MOV AX, @DATA\n\tMOV DS, AX\n\t"+$6->getcode()+"\n\tMOV AH, 4CH\n\tINT 21H\n\tMAIN ENDP\n";
						$$->setcode(code);
					}
					else {
						string code="";
						int x=6+(4*current_par_list.size())+(2*current_temp_list.size())+2;
						//cout<<current_par_list.size()<<endl;
						//cout<<current_temp_list.size()<<endl;
						string return_label=func_name+"ret_";
						code=code+"\n"+$2->getname()+" PROC\n\t"+"PUSH AX\n\tPUSH CX\n\tPUSH DX\n\t";
						for(int i=0;i<current_par_list.size();i++) {
							code=code+"PUSH "+current_par_list[i]+"\n\t";
						}
						for(int i=0;i<current_temp_list.size();i++) {
							code=code + "PUSH "+current_temp_list[i]+"\n\t";
						}
						code=code+"PUSH BP\n\t"+"MOV BP,SP\n\t";
						for(int i=0;i<current_par_list.size();i++) {
							code=code+"MOV AX,[BP+"+inttostring(x)+"]\n\tMOV "+current_par_list[i]+",AX\n\t";
							x=x+2;
						}
						code=code+$6->getcode()+"\n"+return_label+":\n\t";
						code=code+"POP BP\n\t";
						for(int i=current_temp_list.size()-1;i>=0;i--) {
							code=code + "POP "+current_temp_list[i]+"\n\t";
						}
						for(int i=current_par_list.size()-1;i>=0;i--) {
							code=code + "POP "+current_par_list[i]+"\n\t";
						}
						code=code+"POP DX\n\tPOP CX\n\tPOP AX\n\t";
						code=code+"RET"+"\n\t"+$2->getname()+" ENDP\n\t";
						
						$$->setcode(code);
						
						
					}
					//cout<<$$->getcode()<<endl;
					current_par_list.clear();
					current_temp_list.clear();
				}

				| type_specifier ID LPAREN parameter_list error RPAREN 
				{
					int flag=0;
					int alreadyerror=0;
					SymbolInfo *temp=table.Lookup($2->getname());
					SymbolInfo *final=NULL;
					if(temp!=NULL) {
						flag=2;
						if(temp->getrettype()!="" && temp->getvartype()=="DEC") {
							flag=1;
							final=temp;
					}
					else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
						alreadyerror=1;
					}
					}
					if(flag==0){
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					for(int i=0;i<pl.size();i++) {
						funin->setparam(pl[i].first,pl[i].second);
					}
					table.getcurrent()->Insert(funin);
					}
					else if(flag==1) {
						if(final->getrettype()!=$1->getname()) {
							fprintf(logout,"Error at line %d: Return type mismatch with function declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Return type mismatch with function declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
							alreadyerror=1;
						}
						else if(final->getparamlist().size()==1 && final->getparamlist()[0].first=="empty" && final->getparamlist()[0].second=="empty") {
							if(pl.size()!=0) {
							fprintf(logout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
							alreadyerror=1;
							}
						}
						else if(final->getparamlist().size()!=pl.size()) {
							fprintf(logout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Total number of arguments mismatch with declaration in function%s\n\n",line_count,$2->getname().c_str());
							err++;
							alreadyerror=1;

						}
						else {
							int fl=0;
							int num;
							for(int i=0;i<pl.size();i++) {
								if(pl[i].first!=final->getparamlist()[i].first) {
									fl=1;
									num=i;
									break;

								}
							}
							if(fl==1) {
							fprintf(logout,"Error at line %d: %dth parameter's type does not match with declaration in function %s\n\n",line_count,num+1,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: %dth parameter's type does not match with declaration in function %s\n\n",line_count,num+1,$2->getname().c_str());
							err++;
							alreadyerror=1;
							}
						}
						final->setvartype("");
					}
					if(alreadyerror==0) {
						int fl=0;
						int num;
						for(int i=0;i<pl.size();i++) {
							if(pl[i].first!="void" && pl[i].second=="") {
								fl=1;
								num=i;
								break;
							}
						}
						if(fl==1) {
							fprintf(logout,"Error at line %d: %dth parameter's name not given in function definition of %s\n\n",line_count,num+1,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: %dth parameter's name not given in function definition of %s\n\n",line_count,num+1,$2->getname().c_str());
							err++;
						}
					}

					}compound_statement {
					un=un+$1->getname()+" "+$2->getname()+"(";
					for(int i=0;i<pl.size()-1;i++) {
					un=un+pl[i].first+" "+pl[i].second+",";
					}
					un=un+pl[pl.size()-1].first+" "+pl[pl.size()-1].second+")"+$8->getname()+"\n";
					$$=new SymbolInfo(un,"FUNCDEF");
					pl.clear();
					un="";

				}

				| type_specifier ID LPAREN error parameter_list RPAREN
				{
					int flag=0;
					int alreadyerror=0;
					SymbolInfo *temp=table.Lookup($2->getname());
					SymbolInfo *final=NULL;
					if(temp!=NULL) {
						flag=2;
						if(temp->getrettype()!="" && temp->getvartype()=="DEC") {
							flag=1;
							final=temp;
					}
					else {
						fprintf(logout,"Error at line %d: Multiple declaration of  %s\n\n",line_count,$2->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$2->getname().c_str());
						err++;
						alreadyerror=1;
					}
					}
					if(flag==0){
					SymbolInfo *funin=new SymbolInfo($2->getname(),"ID");
					funin->setrettype($1->getname());
					for(int i=0;i<pl.size();i++) {
						funin->setparam(pl[i].first,pl[i].second);
					}
					table.getcurrent()->Insert(funin);
					}
					else if(flag==1) {
						if(final->getrettype()!=$1->getname()) {
							fprintf(logout,"Error at line %d: Return type mismatch with function declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Return type mismatch with function declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
							alreadyerror=1;
						}
						else if(final->getparamlist().size()==1 && final->getparamlist()[0].first=="empty" && final->getparamlist()[0].second=="empty") {
							if(pl.size()!=0) {
							fprintf(logout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
							alreadyerror=1;
							}
						}
						else if(final->getparamlist().size()!=pl.size()) {
							fprintf(logout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: Total number of arguments mismatch with declaration in function %s\n\n",line_count,$2->getname().c_str());
							err++;
							alreadyerror=1;

						}
						else {
							int fl=0;
							int num;
							for(int i=0;i<pl.size();i++) {
								if(pl[i].first!=final->getparamlist()[i].first) {
									fl=1;
									num=i;
									break;

								}
							}
							if(fl==1) {
							fprintf(logout,"Error at line %d: %dth parameter's type does not match with declaration in function %s\n\n",line_count,num+1,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: %dth parameter's type does not match with declaration in function %s\n\n",line_count,num+1,$2->getname().c_str());
							err++;
							alreadyerror=1;
							}
						}
						final->setvartype("");
					}
					if(alreadyerror==0) {
						int fl=0;
						int num;
						for(int i=0;i<pl.size();i++) {
							if(pl[i].first!="void" && pl[i].second=="") {
								fl=1;
								num=i;
								break;
							}
						}
						if(fl==1) {
							fprintf(logout,"Error at line %d: %dth parameter's name not given in function definition of %s\n\n",line_count,num+1,$2->getname().c_str());
							fprintf(errorout,"Error at line %d: %dth parameter's name not given in function definition of %s\n\n",line_count,num+1,$2->getname().c_str());
							err++;
						}
					}

					}compound_statement {
					un=un+$1->getname()+" "+$2->getname()+"(";
					for(int i=0;i<pl.size()-1;i++) {
					un=un+pl[i].first+" "+pl[i].second+",";
					}
					un=un+pl[pl.size()-1].first+" "+pl[pl.size()-1].second+")"+$8->getname()+"\n";
					$$=new SymbolInfo(un,"FUNCDEF");
					pl.clear();
					un="";

				}
				

				;


compound_statement : LCURL
				{
							table.Enter(logout);
							//cout<<to_be_inserted_pl.size()<<endl;
							for(int i=0;i<to_be_inserted_pl.size();i++) {
								SymbolInfo *varin=new SymbolInfo(to_be_inserted_pl[i].second,"ID");
								varin->setvartype(to_be_inserted_pl[i].first);
								varin->setvarid(to_be_inserted_pl[i].second+inttostring(table.getcurrent()->getnewid()));
								asm_variables.push_back(varin->getvarid());
								
								//cout<<"etavariinn"<<varin->getvarid()<<endl;
								table.getcurrent()->Insert(varin);

							}
							for(int i=0;i<to_be_inserted_pl.size();i++) {
						//cout<<pl[i].second<<endl;
						SymbolInfo *sym=table.Lookup(to_be_inserted_pl[i].second);
						if(sym!=NULL) {
						current_par_list.push_back(sym->getvarid());
						//cout<<"parrraa"<<current_par_list[i]<<endl;
						}
					}
							to_be_inserted_pl.clear();
							

							}

							statements RCURL {
					$$=new SymbolInfo("{\n"+$3->getname()+"}","COMSTATE");
					$$->setcode($3->getcode());
					fprintf(logout,"Line %d: compound_statement : LCURL statements RCURL\n\n",line_count);
					fprintf(logout,"{\n%s",$3->getname().c_str());
					fprintf(logout,"}");
					fprintf(logout,"\n\n");
					table.printall(logout);
					
					//to_be_inserted_pl.clear();
					table.Exit(logout);
					
				}

 		    	| LCURL 
				{
				 		table.Enter(logout);
			 			for(int i=0;i<to_be_inserted_pl.size();i++) {
								SymbolInfo *varin=new SymbolInfo(to_be_inserted_pl[i].second,"ID");
								varin->setvartype(to_be_inserted_pl[i].first);
								varin->setvarid(to_be_inserted_pl[i].second+inttostring(table.getcurrent()->getnewid()));
								//cout<<to_be_inserted_pl[i].second<<endl;
								table.getcurrent()->Insert(varin);
							}
							for(int i=0;i<to_be_inserted_pl.size();i++) {
						//cout<<pl[i].second<<endl;
						SymbolInfo *sym=table.Lookup(to_be_inserted_pl[i].second);
						if(sym!=NULL) {
						current_par_list.push_back(sym->getvarid());
						//cout<<"parrraa"<<current_par_list[i]<<endl;
						}
					}
							to_be_inserted_pl.clear();
							
			 	} RCURL {
				$$=new SymbolInfo("{\n}\n","COMSTATE");
				fprintf(logout,"Line %d: compound_statement : LCURL RCURL\n\n",line_count);
				fprintf(logout,"{\n}");
				fprintf(logout,"\n\n");
				table.printall(logout);
				table.Exit(logout);
				//to_be_inserted_pl.clear();
			 	}

 		    	;


statements : statement
		{
		$$=new SymbolInfo($1->getname()+"\n","STATEMENTS");
		fprintf(logout,"Line %d: statements : statement\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n\n");	
		$$->setcode($1->getcode());
		}

		| func_definition 
		{
			$$=new SymbolInfo($1->getname()+"\n","STATEMENTS");
			fprintf(logout,"Line %d: statements : func_definition\n\n",line_count);
			fprintf(logout,"%s",$1->getname().c_str());
			fprintf(logout,"\n\n\n");
			fprintf(logout,"Error at line %d: Invalid scoping\n\n",line_count);
			fprintf(errorout,"Error at line %d: Invalid scoping\n\n",line_count);
			err++;

		}
		| error
		{
			$$= new SymbolInfo("\n","STATEMENTS");
		}

		| func_declaration 
		{
			$$=new SymbolInfo($1->getname()+"\n","STATEMENTS");
			fprintf(logout,"Line %d: statements : func_declaration\n\n",line_count);
			fprintf(logout,"%s",$1->getname().c_str());
			fprintf(logout,"\n\n\n");
			fprintf(logout,"Error at line %d: Invalid scoping\n\n",line_count);
			fprintf(errorout,"Error at line %d: Invalid scoping\n\n",line_count);
			err++;

		}

	   | statements statement
		{
		$$=new SymbolInfo($1->getname()+$2->getname()+"\n","STATEMENTS");
		fprintf(logout,"Line %d: statements : statements statement\n\n",line_count);
		fprintf(logout,"%s%s",$1->getname().c_str(),$2->getname().c_str());
		fprintf(logout,"\n\n\n");	
		$$->setcode($1->getcode()+$2->getcode());
		
	    }

		| statements func_definition 
		{
			$$=new SymbolInfo($1->getname()+$2->getname()+"\n","STATEMENTS");
			fprintf(logout,"Line %d: statements : statements func_definition\n\n",line_count);
			fprintf(logout,"%s",$1->getname().c_str());
			fprintf(logout,"\n\n\n");
			fprintf(logout,"Error at line %d: Invalid scoping\n\n",line_count);
			fprintf(errorout,"Error at line %d: Invalid scoping\n\n",line_count);
			err++;
		}
		| statements func_declaration 
		{
			$$=new SymbolInfo($1->getname()+$2->getname()+"\n","STATEMENTS");
			fprintf(logout,"Line %d: statements : statements func_declaration\n\n",line_count);
			fprintf(logout,"%s",$1->getname().c_str());
			fprintf(logout,"\n\n\n");
			fprintf(logout,"Error at line %d: Invalid scoping\n\n",line_count);
			fprintf(errorout,"Error at line %d: Invalid scoping\n\n",line_count);
			err++;
		}

	   ;


statement : var_declaration
		{
		$$=new SymbolInfo($1->getname(),"STATEMENT");
		fprintf(logout,"Line %d: statement : var_declaration\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n\n");	
		} 

		| compound_statement
		{
		$$=new SymbolInfo($1->getname(),"STATEMENT");
		fprintf(logout,"Line %d: statement : compound_statement\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n\n");	
		$$->setcode($1->getcode());
		}

		| RETURN expression SEMICOLON 
		{
		$$=new SymbolInfo("return "+$2->getname()+";","STATEMENT");
		fprintf(logout,"Line %d: statement : RETURN expression SEMICOLON\n\n",line_count);
		fprintf(logout,"return %s;",$2->getname().c_str());
		fprintf(logout,"\n\n\n");
		string code="";
		if(func_name!="main")	{
		code=$2->getcode()+";returning from procedure\n\t";
		code=code+"MOV BX,"+$2->getvarid()+"\n\tJMP "+func_name+"ret_"+"\n\t";
		}
		$$->setcode(code);
		}
		| RETURN expression error {
			$$=new SymbolInfo("return "+$2->getname()+";","STATEMENT");
		}

 		| expression_statement 
		{
		$$=new SymbolInfo($1->getname(),"STATEMENT");
		fprintf(logout,"Line %d: statement : expression_statement\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n\n");
		$$->setcode($1->getcode());	
		 }

		| FOR LPAREN expression_statement expression_statement expression RPAREN statement 
		{
		//cout<<"hereee"<<endl;
		$$=new SymbolInfo("for("+$3->getname()+$4->getname()+$5->getname()+")"+$7->getname(),"STATEMENT");
		fprintf(logout,"Line %d: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",line_count);
		fprintf(logout,"for(%s%s%s)%s",$3->getname().c_str(),$4->getname().c_str(),$5->getname().c_str(),$7->getname().c_str());
		fprintf(logout,"\n\n\n");	
		string code=$3->getcode()+";for block\n\t";
		string label=newLabel();
		string next_label=newLabel();
		code=code+"\n"+label+":\n\t"+$4->getcode()+"\n\tMOV AX,"+$4->getvarid()+"\n\tCMP AX,0\n\tJE "+next_label+"\n\t"+$7->getcode()+"\n\t"+$5->getcode()+"\n\tJMP "+label+"\n";
		code=code+next_label+":\n\t";
		$$->setcode(code);
		}

	    | IF LPAREN expression RPAREN statement %prec LOW 
		{
		$$=new SymbolInfo("if ("+$3->getname()+")"+$5->getname(),"STATEMENT");
		fprintf(logout,"Line %d: statement : IF LPAREN expression RPAREN statement\n\n",line_count);
		fprintf(logout,"%s",$$->getname().c_str());
		fprintf(logout,"\n\n\n");	
		string code="";
		code=code+$3->getcode()+";if block\n\t";
		string label=newLabel();
		code=code+"MOV AX,"+$3->getvarid()+"\n\t"+"CMP AX,0\n\tJE "+label+"\n\t"+$5->getcode()+"\n";
		code=code+label+":\n\t";
		$$->setcode(code);
		}

	    | IF LPAREN expression RPAREN statement ELSE statement 
		{
		$$=new SymbolInfo("if ("+$3->getname()+")"+$5->getname()+"\n"+"else"+"\n"+$7->getname(),"STATEMENT");
		fprintf(logout,"Line %d: statement : IF LPAREN expression RPAREN statement ELSE statement\n\n",line_count);
		fprintf(logout,"%s",$$->getname().c_str());
		fprintf(logout,"\n\n\n");	
		string code="";
		code=code+$3->getcode()+";if-else block\n\t";
		string label=newLabel();
		string next_label=newLabel();
		code=code+"MOV AX,"+$3->getvarid()+"\n\t"+"CMP AX,0\n\tJE "+label+"\n\t"+$5->getcode()+"JMP "+next_label+"\n";
		code=code+label+":\n\t"+$7->getcode()+"\n";
		code=code+next_label+":\n\t";
		$$->setcode(code);
		}

	    | WHILE LPAREN expression RPAREN statement 
		{
		$$=new SymbolInfo("while ("+$3->getname()+")"+$5->getname(),"STATEMENT");
		fprintf(logout,"Line %d: statement : WHILE LPAREN expression RPAREN statement\n\n",line_count);
		fprintf(logout,"%s",$$->getname().c_str());
		fprintf(logout,"\n\n\n");
		string code=";while block\n\t";
		string label=newLabel();
		string next_label=newLabel();
		code=code+"\n"+label+":\n\t"+$3->getcode()+"\n\tMOV AX,"+$3->getvarid()+"\n\t"+"CMP AX,0\n\tJE "+next_label+"\n\t"+$5->getcode()+"\n\tJMP "+label+"\n";
		code=code+next_label+":\n\t";
		$$->setcode(code);
		}

	    | PRINTLN LPAREN ID RPAREN SEMICOLON 
		{
		$$=new SymbolInfo("printf("+$3->getname()+");","STATEMENT");
		fprintf(logout,"Line %d: statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",line_count);
		if(table.Lookup($3->getname())==NULL) {
			fprintf(logout,"Error at line %d: Undeclared variable %s\n\n",line_count,$3->getname().c_str());
			fprintf(errorout,"Error at line %d: Undeclared variable %s\n\n",line_count,$3->getname().c_str());
			err++;
		}
		else {
		//cout<<$3->getvarid()<<endl;
		string temp=table.Lookup($3->getname())->getvarid();
		//cout<<temp<<endl;
		$$->setcode(";PRINT function\n\tMOV AX,"+temp+"\n\t"+"CALL PRINTLN\n\t");
		}

		fprintf(logout,"%s",$$->getname().c_str());
		fprintf(logout,"\n\n\n");

		}

		| PRINTLN LPAREN ID RPAREN error 
		{
			$$=new SymbolInfo("printf("+$3->getname()+");","STATEMENT");
			if(table.Lookup($3->getname())==NULL) {
			fprintf(logout,"Error at line %d: Undeclared variable %s\n\n",line_count,$3->getname().c_str());
			fprintf(errorout,"Error at line %d: Undeclared variable %s\n\n",line_count,$3->getname().c_str());
			err++;
		}

		}

	    ;


variable : ID 
	{
	fprintf(logout,"Line %d: variable : ID\n\n",line_count);
	SymbolInfo *sym=table.Lookup($1->getname());
	int var=0;
	if(sym==NULL) {
		fprintf(logout,"Error at line %d: Undeclared variable %s\n\n",line_count,$1->getname().c_str());
		fprintf(errorout,"Error at line %d: Undeclared variable %s\n\n",line_count,$1->getname().c_str());
		err++;
		var=1;
	}
	if(sym!=NULL && sym->getrettype()!="") {
		fprintf(logout,"Error at line %d: %s is a function\n\n",line_count,$1->getname().c_str());
		fprintf(errorout,"Error at line %d: %s is a function\n\n",line_count,$1->getname().c_str());
		err++;
		var=1;
	}
	if(sym!=NULL && sym->getvarsize()!=0) {
		fprintf(logout,"Error at line %d: Type mismatch, %s is an array\n\n",line_count,$1->getname().c_str());
		fprintf(errorout,"Error at line %d: Type mismatch, %s is an array\n\n",line_count,$1->getname().c_str());
		err++;
		var=1;
	}
	//cout<<$1->getvarid()<<endl;
	fprintf(logout,"%s",$1->getname().c_str());
	fprintf(logout,"\n\n");
	$$=new SymbolInfo($1->getname(),"VARID");
	if(sym!=NULL){
		$$->setvarid(sym->getvarid());
		//cout<<$$->getvarid()<<endl;
		//cout<<sym->getvarid()+"hereee"<<endl;
	}
	if(var==0)$$->setvartype(sym->getvartype());
	else $$->setvartype("Undeclared");

	}	

	| ID LTHIRD expression RTHIRD 
	{
	
	fprintf(logout,"Line %d: variable : ID LTHIRD expression RTHIRD\n\n",line_count);
	SymbolInfo *sym=table.Lookup($1->getname());
	int var=0;
	if(sym==NULL) {
		fprintf(logout,"Error at line %d: Undeclared variable %s\n\n",line_count,$1->getname().c_str());
		fprintf(errorout,"Error at line %d: Undeclared variable %s\n\n",line_count,$1->getname().c_str());
		err++;
		var=1;
	}

	if(sym!=NULL && sym->getrettype()!="") {
		fprintf(logout,"Error at line %d: %s is a function\n\n",line_count,$1->getname().c_str());
		fprintf(errorout,"Error at line %d: %s is a function\n\n",line_count,$1->getname().c_str());
		err++;
		var=1;
		
	}

	if(sym!=NULL && sym->getvarsize()==0) {
		fprintf(logout,"Error at line %d: %s is not an array\n\n",line_count,$1->getname().c_str());
		fprintf(errorout,"Error at line %d: %s is not an array\n\n",line_count,$1->getname().c_str());
		err++;
		var=1;
	}

	if($3->getvartype()!="int") {
		fprintf(logout,"Error at line %d: Expression inside third brackets not an integer\n\n",line_count);
		fprintf(errorout,"Error at line %d: Expression inside third brackets not an integer\n\n",line_count);
		err++;
	}

	fprintf(logout,"%s[%s]",$1->getname().c_str(),$3->getname().c_str());
	fprintf(logout,"\n\n");
	$$=new SymbolInfo($1->getname()+"["+$3->getname()+"]","VARARR");
	string id="";
	if(sym!=NULL) id=sym->getvarid();
	if(var==0)$$->setvartype(sym->getvartype());
	else $$->setvartype("Undeclared");
	string code=$3->getcode();
	code=code+"MOV BX,"+$3->getvarid()+"\n\t"+"ADD BX,BX\n\t";
	$$->setcode(code);
	$$->setvarid(id);
	}

	;
	 

expression : logic_expression	
		{
		$$=new SymbolInfo($1->getname(),"EXP");
		fprintf(logout,"Line %d: expression : logic expression\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvartype($1->getvartype());
		$$->setvarid($1->getvarid());
		$$->setcode($1->getcode());
		}

	   | variable ASSIGNOP logic_expression 
	   {
		    int var=0;
		   	$$=new SymbolInfo($1->getname()+"="+$3->getname(),"EXP");
			fprintf(logout,"Line %d: expression : variable ASSIGNOP logic_expression\n\n",line_count);
			if(($1->getvartype()!="Undeclared") && ($3->getvartype()!="Undeclared")){
			if($1->getvartype()=="void"||$3->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++; 
				var=1; 
			  }
			
			else if(($1->getvartype()!="float" )&& ($3->getvartype()!="int") && ($1->getvartype()!=$3->getvartype()))
			{
			fprintf(logout,"Error at line %d: Type Mismatch\n\n",line_count,$3->getname().c_str());
			fprintf(errorout,"Error at line %d: Type Mismatch\n\n",line_count,$3->getname().c_str());
			err++;
			var=1;
			}
		  }
			//else var=-1;
			fprintf(logout,"%s=%s",$1->getname().c_str(),$3->getname().c_str());
			fprintf(logout,"\n\n");

			if($1->gettype()=="VARID")$$->setcode($1->getcode()+$3->getcode()+"MOV AX,"+$3->getvarid()+"\n\t"+"MOV "+$1->getvarid()+",AX"+"\n\t");
			else  $$->setcode($1->getcode()+$3->getcode()+";"+$1->getname()+"="+$3->getname()+"\n\t"+"MOV AX,"+$3->getvarid()+"\n\t"+"MOV "+$1->getvarid()+"[BX], AX"+"\n\t");
			$$->setvarid($1->getvarid());
			if(var==0)$$->setvartype($1->getvartype());
			else $$->setvartype("Undeclared");
	    }

		 | variable ASSIGNOP error logic_expression 
	   {
		    int var=0;
		   	$$=new SymbolInfo($1->getname()+"="+$4->getname(),"EXP");
			if(($1->getvartype()!="Undeclared") && ($4->getvartype()!="Undeclared")){
			if($1->getvartype()=="void"||$4->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++; 
				var=1; 
			}
			
			else if(($1->getvartype()!="float" )&& ($4->getvartype()!="int") && ($1->getvartype()!=$4->getvartype()))
			{
			fprintf(logout,"Error at line %d: Type Mismatch\n\n",line_count,$4->getname().c_str());
			fprintf(errorout,"Error at line %d: Type Mismatch\n\n",line_count,$4->getname().c_str());
			err++;
			var=1;
			}
		  }
			//var=-1;
			
			if(var==0)$$->setvartype($1->getvartype());
			else $$->setvartype("Undeclared");
	   }
	   ;


expression_statement 	: SEMICOLON	
		{
		$$=new SymbolInfo(";","EXPSTATE");
		fprintf(logout,"Line %d: expression_statement : SEMICOLON\n\n",line_count);
		fprintf(logout,";");
		fprintf(logout,"\n\n");
		}

		| expression SEMICOLON  
		{
			$$=new SymbolInfo($1->getname()+";","EXPSTATE");
			fprintf(logout,"Line %d: expression_statement : expression SEMICOLON\n\n",line_count);
			fprintf(logout,"%s;",$1->getname().c_str());
			fprintf(logout,"\n\n");
			$$->setcode($1->getcode());
			$$->setvarid($1->getvarid());
		}
		| expression error {
			//cout<<"gerrr"<<endl;
			//yyerror("here");
			$$=new SymbolInfo($1->getname()+";","EXPSTATE");
		}
			

		;	
		
			
logic_expression : rel_expression 
	{
		$$=new SymbolInfo($1->getname(),"LOGEX");
		fprintf(logout,"Line %d: logic_expression : rel_expression\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvartype($1->getvartype());
		$$->setvarid($1->getvarid());
		$$->setcode($1->getcode());
	}

		 | rel_expression LOGICOP rel_expression 
		 {
			 int var=0;
			$$=new SymbolInfo($1->getname()+$2->getname()+$3->getname(),"LOGEX");
			fprintf(logout,"Line %d: logic_expression : rel_expression LOGICOP rel_expression\n\n",line_count);
			if($1->getvartype()!="Undeclared" && $3->getvartype()!="Undeclared") {
				if($1->getvartype()=="void"||$3->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++;  
				var=1;
			}
			}
			//var=-1;
			fprintf(logout,"%s%s%s",$1->getname().c_str(),$2->getname().c_str(),$3->getname().c_str());
			fprintf(logout,"\n\n");
			if(var==0)$$->setvartype("int");
			else $$->setvartype("Undeclared");
			string code=$1->getcode()+$3->getcode()+";"+$1->getname()+$2->getname()+$3->getname()+"\n\t";
			code=code+"MOV AX,"+$1->getvarid()+"\n\t";
			string temp=newTemp();
			string label=newLabel();
			string next_label=newLabel();
			if($2->getname()=="&&") {
				code=code+"CMP AX,0\n\tJE "+label+"\n\t";
				code=code+"MOV AX,"+$3->getvarid()+"\n\t"+"CMP AX,0\n\tJE "+label+"\n\t";
				code=code+"MOV "+temp+",1\n\tJMP "+next_label+"\n";
				code=code+label+":\n\t"+"MOV "+temp+",0\n";
			}
			if($2->getname()=="||") {
				code=code+"CMP AX,1\n\tJE "+label+"\n\t";
				code=code+"MOV AX,"+$3->getvarid()+"\n\tCMP AX,1\n\tJE "+label+"\n\t";
				code=code+"MOV "+temp+",0\n\tJMP "+next_label+"\n";
				code=code+label+":\n\t"+"MOV "+temp+",1\n";
			}
			code=code+next_label+":\n\t";
			$$->setcode(code);
			asm_variables.push_back(temp);
			current_temp_list.push_back(temp);
			$$->setvarid(temp);
		 }

		| rel_expression LOGICOP error rel_expression 

		 {
			 int var=0;
			$$=new SymbolInfo($1->getname()+$2->getname()+$4->getname(),"LOGEX");
			if($1->getvartype()!="Undeclared" && $4->getvartype()!="Undeclared") {
				if($1->getvartype()=="void"||$4->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++;  
				var=1;
			}
		  }
			//var=-1;
			if(var==0)$$->setvartype("int");
			else $$->setvartype("Undeclared");
		 }

		 ;


rel_expression	: simple_expression 
		{
		$$=new SymbolInfo($1->getname(),"RELEX");
		fprintf(logout,"Line %d: rel_expression : simple_expression\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n");
		//cout<<"hereeee"<<endl;
		$$->setvartype($1->getvartype());
		$$->setvarid($1->getvarid());
		$$->setcode($1->getcode());
	
		}

		| 	simple_expression RELOP simple_expression	
		{
			int var=0;
			$$=new SymbolInfo($1->getname()+$2->getname()+$3->getname(),"RELEX");
			fprintf(logout,"Line %d: rel_expression : simple_expression RELOP simple_expression\n\n",line_count);
			if($1->getvartype()!="Undeclared" && $3->getvartype()!="Undeclared") {
			if($1->getvartype()=="void"||$3->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++;  
				var=1;
			}
			}
			fprintf(logout,"%s%s%s",$1->getname().c_str(),$2->getname().c_str(),$3->getname().c_str());
			fprintf(logout,"\n\n");
			if(var==0)$$->setvartype("int");
			else $$->setvartype("Undeclared");
			string code=$1->getcode()+$3->getcode()+";"+$1->getname()+$2->getname()+$3->getname()+"\n\t";
			code=code+"MOV AX,"+$1->getvarid()+"\n\t"+"CMP AX,"+$3->getvarid()+"\n\t";
			string temp=newTemp();
			string label=newLabel();
			string next_label=newLabel();
			if($2->getname()==">") {
				code=code+"JG "+label+"\n\t"+"MOV "+temp+",0\n\tJMP "+next_label+"\n";
			}
			if($2->getname()=="<") {
				code=code+"JL "+label+"\n\t"+"MOV "+temp+",0\n\tJMP "+next_label+"\n";
			}
			if($2->getname()==">=") {
				code=code+"JGE "+label+"\n\t"+"MOV "+temp+",0\n\tJMP "+next_label+"\n";
			}
			if($2->getname()=="<=") {
				code=code+"JLE "+label+"\n\t"+"MOV "+temp+",0\n\tJMP "+next_label+"\n";
			}
			if($2->getname()=="==") {
				code=code+"JE "+label+"\n\t"+"MOV "+temp+",0\n\tJMP "+next_label+"\n";
			}
			if($2->getname()=="!=") {
				code=code+"JNE "+label+"\n\t"+"MOV "+temp+",0\n\tJMP "+next_label+"\n";
			}
			code=code+label+":\n\tMOV "+temp+",1\n"+next_label+":\n\t";
			asm_variables.push_back(temp);
			current_temp_list.push_back(temp);
			$$->setcode(code);
			$$->setvarid(temp);
		}

		| simple_expression RELOP error simple_expression {
			int var=0;
			$$=new SymbolInfo($1->getname()+$2->getname()+$4->getname(),"RELEX");
			if($1->getvartype()!="Undeclared" && $4->getvartype()!="Undeclared") {
			if($1->getvartype()=="void"||$4->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++;  
				var=1;
			}
			}
			//else var=-1;
			if(var==0)$$->setvartype("int");
			else $$->setvartype("Undeclared");
		}
		

		;


simple_expression : term  
	{
		$$=new SymbolInfo($1->getname(),"SIMPEX");
		fprintf(logout,"Line %d: simple_expression : term\n\n",line_count);
		
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvartype($1->getvartype());
		$$->setvarid($1->getvarid());
		$$->setcode($1->getcode());
	}

		  | simple_expression ADDOP term  
		  {
			  int var=0;
			  $$=new SymbolInfo($1->getname()+$2->getname()+$3->getname(),"SIMPEX");
			  fprintf(logout,"Line %d: simple_expression : simple_expression ADDOP term\n\n",line_count);
			  if($1->getvartype()!="Undeclared" && $3->getvartype()!="Undeclared") {
			  if($1->getvartype()=="void"||$3->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++;  
				var=1;
			}
			  }
			//else var=-1;
			  fprintf(logout,"%s%s%s",$1->getname().c_str(),$2->getname().c_str(),$3->getname().c_str());
			  fprintf(logout,"\n\n");
			 if(var==0) {
			  if($1->getvartype()=="float"||$3->getvartype()=="float") {
				  $$->setvartype("float");
			  }
			  else $$->setvartype("int");
			 }
			else $$->setvartype("Undeclared");
			 string sign="ADD";
			 if($2->getname()=="-")sign="SUB";
			 string temp=newTemp();
			
			 $$->setcode($1->getcode()+$3->getcode()+";"+$1->getname()+$2->getname()+$3->getname()+"\n\t"+"MOV AX,"+$1->getvarid()+"\n\t"+sign+" AX,"+$3->getvarid()+"\n\t"+"MOV "+temp+",AX\n\t");
			 $$->setvarid(temp);
			 asm_variables.push_back(temp);
			 current_temp_list.push_back(temp);

			 //cout<<$$->getvartype()<<endl;

		  }

		  | simple_expression ADDOP error term 
		  {
			  int var=0;
			  $$=new SymbolInfo($1->getname()+$2->getname()+$4->getname(),"SIMPEX");
			  if($1->getvartype()!="Undeclared" && $4->getvartype()!="Undeclared") {
			  if($1->getvartype()=="void"||$4->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++;  
				var=1;
			   }
			}
			//else var=-1;
			if(var==0) {
			  if($1->getvartype()=="float"||$4->getvartype()=="float") {
				  $$->setvartype("float");
			  }
			  else $$->setvartype("int");
			 }
			 else $$->setvartype("Undeclared");
			 //cout<<$$->getvartype()<<endl;
		  }

		  ;


term :	unary_expression 
	{
		$$=new SymbolInfo($1->getname(),"TERM");
		fprintf(logout,"Line %d: term : unary_expression\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvartype($1->getvartype());
		$$->setvarid($1->getvarid());
		$$->setcode($1->getcode());
	}

	|  term MULOP unary_expression 
	{
		int var=0;
		$$=new SymbolInfo($1->getname()+$2->getname()+$3->getname(),"TERM");
		//cout<<$$->getname()<<endl;
		fprintf(logout,"Line %d: term :	term MULOP unary_expression\n\n",line_count);
		if($1->getvartype()!="Undeclared" && $3->getvartype()!="Undeclared") {
		if($1->getvartype()=="void"||$3->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++;
				var=1;
		}

		else if(($2->getname()=="%")&&($1->getvartype()!="int"||$3->getvartype()!="int")) {
				fprintf(logout,"Error at line %d: Non-Integer operand on modulus operator\n\n",line_count);
				fprintf(errorout,"Error at line %d: Non-Integer operand on modulus operator\n\n",line_count);
				err++;
				var=1;
		}
		else if(($2->getname()=="%")&& ($3->getname()=="0")) {
				fprintf(logout,"Error at line %d: Modulus by zero\n\n",line_count);
				fprintf(errorout,"Error at line %d: Modulus by zero\n\n",line_count);
				err++;
				var=1;
		}
		else if(($2->getname()=="/")&& ($3->getname()=="0")) {
				fprintf(logout,"Error at line %d: Division by zero\n\n",line_count);
				fprintf(errorout,"Error at line %d: Division by zero\n\n",line_count);
				err++;
				var=1;
		   }
		}
		//else var=-1;
		fprintf(logout,"%s%s%s",$1->getname().c_str(),$2->getname().c_str(),$3->getname().c_str());
		fprintf(logout,"\n\n");
		
		if(var==0){
			if(($2->getname()=="*"||$2->getname()=="/")&&($1->getvartype()=="float"||$3->getvartype()=="float")) {
				  $$->setvartype("float");
			  }
		else $$->setvartype("int");
		}
		else $$->setvartype("Undeclared");
		string op="IMUL";
		if($2->getname()=="/")op="IDIV";
		if($2->getname()=="%")op="MOD";
		string temp=newTemp();
		string code=$1->getcode()+$3->getcode()+";"+$1->getname()+$2->getname()+$3->getname()+"\n\t";
		if(op=="IMUL"||op=="IDIV"){
			code=code+"MOV AX,"+$1->getvarid()+"\n\t"+"MOV BX,"+$3->getvarid()+"\n\t"+"XOR DX,DX\n\t"+op+" BX\n\t"+"MOV "+temp+",AX\n\t";
		}
		else {
			code=code+"MOV AX,"+$1->getvarid()+"\n\t"+"MOV BX,"+$3->getvarid()+"\n\t"+"XOR DX,DX\n\tIDIV BX\n\t"+"MOV "+temp+",DX\n\t";
		}
			$$->setcode(code);
			 $$->setvarid(temp);
			 asm_variables.push_back(temp);
			 current_temp_list.push_back(temp);

		//cout<<"lllll"<<$$->getvartype()<<endl;
	}

	| term MULOP error unary_expression
	{
		int var=0;
		$$=new SymbolInfo($1->getname()+$2->getname()+$4->getname(),"TERM");
		fprintf(logout,"Line %d: term :	term MULOP unary_expression\n\n",line_count);
		if($1->getvartype()!="Undeclared" && $4->getvartype()!="Undeclared") {
		if($1->getvartype()=="void"||$4->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++;
				var=1;
		}

		else if(($2->getname()=="%")&&($1->getvartype()!="int"||$4->getvartype()!="int")) {
				fprintf(logout,"Error at line %d: Non-Integer operand on modulus operator\n\n",line_count);
				fprintf(errorout,"Error at line %d: Non-Integer operand on modulus operator\n\n",line_count);
				err++;
				var=1;
		}
		else if(($2->getname()=="%")&& ($4->getname()=="0")) {
				fprintf(logout,"Error at line %d: Modulus by zero\n\n",line_count);
				fprintf(errorout,"Error at line %d: Modulus by zero\n\n",line_count);
				err++;
				var=1;
		}
		else if(($2->getname()=="/")&& ($4->getname()=="0")) {
				fprintf(logout,"Error at line %d: Division by zero\n\n",line_count);
				fprintf(errorout,"Error at line %d: Division by zero\n\n",line_count);
				err++;
				var=1;
		}
		}
		//else var=-1;
		if(var==0){
			if(($2->getname()=="*"||$2->getname()=="/")&&($1->getvartype()=="float"||$4->getvartype()=="float")) {
				  $$->setvartype("float");
			  }
		else $$->setvartype("int");
		}
		else $$->setvartype("Undeclared");
	}
     
     ;


unary_expression : factor 
		{
		$$=new SymbolInfo($1->getname(),"UNIEX");
		fprintf(logout,"Line %d: unary_expression : factor\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvartype($1->getvartype());
		$$->setvarid($1->getvarid());
		$$->setcode($1->getcode());
		}

		| ADDOP unary_expression 
		{
		int var=0;
		$$=new SymbolInfo($1->getname()+$2->getname(),"UNIEX");
		fprintf(logout,"Line %d: unary_expression : ADDOP unary_expression\n\n",line_count);
		if($2->getvartype()!="Undeclared")
				{
				if($2->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++; 
				var=1; 
			}
		  }
		//else var=-1;
		fprintf(logout,"%s %s",$1->getname().c_str(),$2->getname().c_str());
		fprintf(logout,"\n\n");
		if(var==0)$$->setvartype($2->getvartype());
		else $$->setvartype("Undeclared");
		string temp=newTemp();
		string code=$2->getcode()+";"+$1->getname()+$2->getname()+"\n\t";
		if($1->getname()=="-") {
			code=code+"MOV AX,"+$2->getvarid()+"\n\t"+"MOV "+temp+",AX\n\t"+"NEG "+temp+"\n\t";
		}
		$$->setcode(code);
		$$->setvarid(temp);
		asm_variables.push_back(temp);
		current_temp_list.push_back(temp);
		}

		| NOT unary_expression
		{
		int var=0;
		$$=new SymbolInfo("!"+$2->getname(),"UNIEX");
		fprintf(logout,"Line %d: unary_expression : NOT unary_expression\n\n",line_count);
		if($2->getvartype()!="Undeclared") {
		if($2->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++;  
				var=1;
		}
		}
		//else var=-1;
		fprintf(logout,"!%s",$2->getname().c_str());
		fprintf(logout,"\n\n");
		if(var==0)$$->setvartype($2->getvartype());
		else $$->setvartype("Undeclared");
		string code=$2->getcode()+";!"+$2->getname()+"\n\t";
		string temp=newTemp();
		string label=newLabel();
		string next_label=newLabel();
		code=code+"MOV AX,"+$2->getvarid()+"\n\t"+"CMP AX,0\n\t"+"JE "+label+"\n\tMOV AX,0\n\tMOV "+temp+",AX\n\tJMP "+next_label+"\n";
		code=code+label+":\n\tMOV AX,1\n\t"+"MOV "+temp+",AX\n"+next_label+":\n\t";
		$$->setcode(code);
		$$->setvarid(temp);
		asm_variables.push_back(temp);
		current_temp_list.push_back(temp);

		}

		| NOT error unary_expression
		{
		int var=0;
		$$=new SymbolInfo("!"+$3->getname(),"UNIEX");
		if($3->getvartype()!="Undeclared") {
		if($3->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++;  
				var=1;
		    }
		}
		//else var=-1;
		if(var==0)$$->setvartype($3->getvartype());
		else $$->setvartype("Undeclared");
		}

		;


factor	: variable 
		{
		$$=new SymbolInfo($1->getname(),"FACTOR");
		fprintf(logout,"Line %d: factor : variable\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvartype($1->getvartype());
		if($1->gettype()=="VARID"){
			$$->setvarid($1->getvarid());
			$$->setcode($1->getcode());		
		}
		else {
			string code="";
			string temp=newTemp();
			code=code+"MOV AX,"+$1->getvarid()+"[BX]\n\t";
			code=code+"MOV "+temp+",AX\n\t";
			$$->setcode(code);
			$$->setvarid(temp);
			asm_variables.push_back(temp);
			current_temp_list.push_back(temp);

		}
		
		}

		| ID LPAREN argument_list RPAREN 
		{
		
		fprintf(logout,"Line %d: factor : ID LPAREN argument_list RPAREN\n\n",line_count);
		SymbolInfo *sym=table.Lookup($1->getname());
		$$=new SymbolInfo($1->getname()+"("+$3->getname()+")","FACTOR");
		if(sym==NULL) {
			fprintf(logout,"Error at line %d: Undeclared function %s\n\n",line_count,$1->getname().c_str());
			fprintf(errorout,"Error at line %d: Undeclared function %s\n\n",line_count,$1->getname().c_str());
			err++;
			$$->setvartype("Undeclared");
		}
		else  {
			int x=sym->getparamlist().size();
			int var=0;
			if (sym->getrettype()=="") {
				fprintf(logout,"Error at line %d: %s is not a function\n\n",line_count,$1->getname().c_str());
				fprintf(errorout,"Error at line %d: %s is not a function\n\n",line_count,$1->getname().c_str());
				err++;
				var=1;
			}
			else if(x==1 && sym->getparamlist()[0].first=="empty" && sym->getparamlist()[0].second=="empty") {
				if(al.size()!=0)  {
				fprintf(logout,"Error at line %d: Total number of arguments mismatch in function %s\n\n",line_count,$1->getname().c_str());
				fprintf(errorout,"Error at line %d: Total number of arguments mismatch in function %s\n\n",line_count,$1->getname().c_str());
				err++;
				var=1;
				}
			}
			else if(sym->getparamlist().size()!=al.size()) {
				//x!=1 && al.size()!=0 && sym->getparamlist()[0].first!="void" && 
				if(x==1 &&  al.size()==0 && sym->getparamlist()[0].first=="void") {

				}
				//cout<<"kiiii"<<endl;
				else {
				fprintf(logout,"Error at line %d: Total number of arguments mismatch in function %s\n\n",line_count,$1->getname().c_str());
				fprintf(errorout,"Error at line %d: Total number of arguments mismatch in function %s\n\n",line_count,$1->getname().c_str());
				err++;
				var=1;
			 }
			}

			else {
				
				int flag=0;
				int num;
				for(int i=0;i<al.size();i++) {
					
					if(al[i].first!="Undeclared") {
					
					if(sym->getparamlist()[i].first!=al[i].first) {
						if(sym->getparamlist()[i].first!="float" && al[i].first!="int"){
						flag=1;
						num=i;
						break;
					 }
					}
				}
			}
				if(flag==1) {
					fprintf(logout,"Error at line %d: %dth argument mismatch in function %s\n\n",line_count,num+1,$1->getname().c_str());
					fprintf(errorout,"Error at line %d: %dth argument mismatch in function %s\n\n",line_count,num+1,$1->getname().c_str());
					err++;
					var=1;
				}
				
			}
			if(var==0)$$->setvartype(sym->getrettype());
			else $$->setvartype("Undeclared");
			
		}
		string temp=newTemp();
		string code=$3->getcode()+";procedure "+$1->getname()+" call\n\t";
		for(int i=current_arg_list.size()-1;i>=0;i--){
			code=code+"PUSH "+current_arg_list[i]+"\n\t";
		}
		code=code+"CALL "+$1->getname()+"\n\t";
		code=code+"MOV AX,BX\n\t"+"MOV "+temp+",AX\n\t";
		$$->setcode(code);
		$$->setvarid(temp);
		asm_variables.push_back(temp);
		current_temp_list.push_back(temp);
		fprintf(logout,"%s(%s)",$1->getname().c_str(),$3->getname().c_str());
		fprintf(logout,"\n\n");
		al.clear();
		current_arg_list.clear();
		}
   
        | ID LPAREN argument_list error RPAREN 
		{
		//cout<<"hereeee"<<endl;
		SymbolInfo *sym=table.Lookup($1->getname());
		$$=new SymbolInfo($1->getname()+"("+$3->getname()+")","FACTOR");
		if(sym==NULL) {
			fprintf(logout,"Error at line %d: Undeclared function %s\n\n",line_count,$1->getname().c_str());
			fprintf(errorout,"Error at line %d: Undeclared function %s\n\n",line_count,$1->getname().c_str());
			err++;
			$$->setvartype("Undeclared");
		}
		else  {
			int x=sym->getparamlist().size();
			int var=0;
			if (sym->getrettype()=="") {
				fprintf(logout,"Error at line %d: %s is not a function\n\n",line_count,$1->getname().c_str());
				fprintf(errorout,"Error at line %d: %s is not a function\n\n",line_count,$1->getname().c_str());
				err++;
				var=1;
			}
			else if(x==1 && sym->getparamlist()[0].first=="empty" && sym->getparamlist()[0].second=="empty") {
				if(al.size()!=0)  {
				fprintf(logout,"Error at line %d: Total number of arguments mismatch in function %s\n\n",line_count,$1->getname().c_str());
				fprintf(errorout,"Error at line %d: Total number of arguments mismatch in function %s\n\n",line_count,$1->getname().c_str());
				err++;
				var=1;
				}
			}

			else if(x!=1 && al.size()!=0 && sym->getparamlist()[0].first!="void" && (sym->getparamlist().size()!=al.size())) {
				//cout<<"kiiii"<<endl;
				fprintf(logout,"Error at line %d: Total number of arguments mismatch in function %s\n\n",line_count,$1->getname().c_str());
				fprintf(errorout,"Error at line %d: Total number of arguments mismatch in function %s\n\n",line_count,$1->getname().c_str());
				err++;
				var=1;
			 }

			else {
				
				int flag=0;
				int num;
				for(int i=0;i<al.size();i++) {
					
					if(al[i].first!="Undeclared") {
					
					if(sym->getparamlist()[i].first!=al[i].first) {
						if(sym->getparamlist()[i].first!="float" && al[i].first!="int"){
						flag=1;
						num=i;
						break;
					 }
					}
				}
			}
				if(flag==1) {
					fprintf(logout,"Error at line %d: %dth argument mismatch in function %s\n\n",line_count,num+1,$1->getname().c_str());
					fprintf(errorout,"Error at line %d: %dth argument mismatch in function %s\n\n",line_count,num+1,$1->getname().c_str());
					err++;
					var=1;
				}
				
			}
			if(var==0)$$->setvartype(sym->getrettype());
			else $$->setvartype("Undeclared");
			
		}
		al.clear();
		}
		
		| CONST_INT 
		{
		$$=new SymbolInfo($1->getname(),"FACTOR");
		fprintf(logout,"Line %d: factor : CONST_INT\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvartype("int"); 
		$$->setvarid($1->getname());

		}

		| CONST_FLOAT 
		{
		$$=new SymbolInfo($1->getname(),"FACTOR");
		fprintf(logout,"Line %d: factor : CONST_FLOAT\n\n",line_count);
		fprintf(logout,"%s",$1->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvartype("float");
		
		$$->setvarid($1->getname());

		}

		| LPAREN expression RPAREN 
		{
		int var=0;
		$$=new SymbolInfo("("+$2->getname()+")","FACTOR");
		fprintf(logout,"Line %d: factor	: LPAREN expression RPAREN\n\n",line_count);
		if($2->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++; 
				var=1; 
		}
		fprintf(logout,"(%s)",$2->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvarid($2->getvarid());
		$$->setcode($2->getcode());
		if(var==0)$$->setvartype($2->getvartype());
		else $$->setvartype("Undeclared");
		}

		| variable INCOP 
		{
		$$=new SymbolInfo($1->getname()+"++","FACTOR");
		fprintf(logout,"Line %d: factor	: variable INCOP\n\n",line_count);
		fprintf(logout,"%s++",$1->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvartype($1->getvartype());
		string temp=newTemp();
		string code=$1->getcode()+";"+$1->getname()+"++\n\t";
		if($1->gettype()=="VARID") {
			code=code+"MOV AX,"+$1->getvarid()+"\n\t"+"MOV "+temp+",AX\n\t"+"INC "+$1->getvarid()+"\n\t";	
		}
		else {
			code=code+"MOV AX,"+$1->getvarid()+"[BX]\n\t"+"MOV "+temp+",AX\n\t"+"INC "+$1->getvarid()+"[BX]\n\t";
		}
		$$->setcode(code);
		$$->setvarid(temp);
		asm_variables.push_back(temp);
		current_temp_list.push_back(temp);

		}

		| variable DECOP 
		{
		$$=new SymbolInfo($1->getname()+"--","FACTOR");
		fprintf(logout,"Line %d: factor	: variable DECOP\n\n",line_count);
		fprintf(logout,"%s--",$1->getname().c_str());
		fprintf(logout,"\n\n");
		$$->setvartype($1->getvartype());
		string temp=newTemp();
		string code=$1->getcode()+";"+$1->getname()+"++\n\t";
		if($1->gettype()=="VARID") {
			code=code+"MOV AX,"+$1->getvarid()+"\n\t"+"MOV "+temp+",AX\n\t"+"DEC "+$1->getvarid()+"\n\t";	
		}
		else {
			code=code+"MOV AX,"+$1->getvarid()+"[BX]\n\t"+"MOV "+temp+",AX\n\t"+"DEC "+$1->getvarid()+"[BX]\n\t";
		}
		$$->setcode(code);
		$$->setvarid(temp);
		asm_variables.push_back(temp);
		current_temp_list.push_back(temp);

		}

		;
	

parameter_list  : parameter_list COMMA type_specifier ID 
		{
			//cout<<$4->getname()<<endl;
			//int flag=0;
			int i;
			fprintf(logout,"Line %d: parameter_list : parameter_list COMMA type_specifier ID\n\n",line_count);
			for(i=0;i<pl.size();i++) {
					if(pl[i].second==$4->getname()) {
						fprintf(logout,"Error at line %d: Multiple declaration of %s in parameter\n\n",line_count,$4->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s in parameter\n\n",line_count,$4->getname().c_str());
						err++;
						break;
					}
					
			}
			if(i==pl.size()) {
				
						//cout<<$3->getname()<<endl;
						//cout<<"heree"<<$4->getname()<<endl;
						to_be_inserted_pl.push_back(std::make_pair($3->getname(),$4->getname()));
			}
			
			for(int i=0;i<pl.size();i++) {
					fprintf(logout,"%s %s,",pl[i].first.c_str(),pl[i].second.c_str());
				}
			fprintf(logout,"%s %s",$3->getname().c_str(),$4->getname().c_str());
			fprintf(logout,"\n\n");
			pl.push_back(std::make_pair($3->getname(),$4->getname()));
			

		}
		

		| parameter_list COMMA type_specifier
		{
			fprintf(logout,"Line %d: parameter_list : parameter_list COMMA type_specifier\n\n",line_count);
			for(int i=0;i<pl.size();i++) {
					fprintf(logout,"%s %s,",pl[i].first.c_str(),pl[i].second.c_str());
				}
			fprintf(logout,$3->getname().c_str());
			fprintf(logout,"\n\n");
			pl.push_back(std::make_pair($3->getname(),""));
			

		}
		

 		| type_specifier ID
		{
			fprintf(logout,"Line %d: parameter_list : type_specifier ID\n\n",line_count);
			fprintf(logout,"%s %s",$1->getname().c_str(),$2->getname().c_str());
			fprintf(logout,"\n\n");
			pl.push_back(std::make_pair($1->getname(),$2->getname()));
			to_be_inserted_pl.push_back(std::make_pair($1->getname(),$2->getname()));
			
			
		}

		| type_specifier 
		{
			fprintf(logout,"Line %d: parameter_list : type_specifier\n\n",line_count);
			fprintf(logout,"%s",$1->getname().c_str());
			fprintf(logout,"\n\n");
			pl.push_back(std::make_pair($1->getname(),""));
			//to_be_inserted_pl.push_back(std::make_pair($1->getname(),""));
		}

		| parameter_list error COMMA type_specifier
		{
			
			pl.push_back(std::make_pair($4->getname(),""));
			//to_be_inserted_pl.push_back(std::make_pair($3->getname(),""));

		}

		| parameter_list error COMMA type_specifier ID 
		{
			int i;
			for(i=0;i<pl.size();i++) {
					if(pl[i].second==$5->getname()) {
						fprintf(logout,"Error at line %d: Multiple declaration of %s in parameter\n\n",line_count,$5->getname().c_str());
						fprintf(errorout,"Error at line %d: Multiple declaration of %s in parameter\n\n",line_count,$5->getname().c_str());
						err++;
						break;
					}
					
				}
			if(i==pl.size())to_be_inserted_pl.push_back(std::make_pair($4->getname(),$5->getname()));
			pl.push_back(std::make_pair($4->getname(),$5->getname()));

		}

 		;


declaration_list : declaration_list COMMA ID
				{
				if(table.Look_current($3->getname())!=NULL) {
								fprintf(logout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$3->getname().c_str());
								fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$3->getname().c_str());
								err++;
				}
				
				else to_be_inserted_dl.push_back($3);  
				$3->setvarid($3->getname()+inttostring(table.getcurrent()->getnewid()));
				$3->settype("NOTARRAY");
				
				fprintf(logout,"Line %d: declaration_list : declaration_list COMMA ID\n\n",line_count);
				for(int i=0;i<dl.size();i++) {
					fprintf(logout,"%s,",dl[i]->getname().c_str());
				}
				fprintf(logout,$3->getname().c_str());
				fprintf(logout,"\n\n");
				dl.push_back($3);
				}

				| ID 
				
				{
					if(table.Look_current($1->getname())!=NULL) {
								fprintf(logout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$1->getname().c_str());
								fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$1->getname().c_str());
								err++;
					}
                    else to_be_inserted_dl.push_back($1);
					$1->setvarid($1->getname()+inttostring(table.getcurrent()->getnewid()));
					//cout<<$1->getvarid()<<endl;
					$1->settype("NOTARRAY");
					dl.push_back($1);
					//cout<<"ID  :ID"<<endl;
					fprintf(logout,"Line %d: declaration_list : ID\n\n",line_count);
					fprintf(logout,"%s",$1->getname().c_str());
					fprintf(logout,"\n\n");
					
				}

				| ID LTHIRD error CONST_INT RTHIRD 
				 {
					if(table.Look_current($1->getname())!=NULL) {
								fprintf(logout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$1->getname().c_str());
								fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$1->getname().c_str());
								err++;
					}
					else {
					SymbolInfo *t=new SymbolInfo($1->getname()+"["+$4->getname()+"]","ARRAY");
					t->setvarsize(std::stoi($4->getname()));
					t->setvarid($1->getname()+inttostring(table.getcurrent()->getnewid()));
					to_be_inserted_dl.push_back(t);
					}
				
					SymbolInfo *temp=new SymbolInfo($1->getname()+"["+$4->getname()+"]","ARRAY");
					temp->setvarsize(std::stoi($4->getname()));
					dl.push_back(temp);
				}

				| ID LTHIRD error RTHIRD 
				{
	
				}

				| ID LTHIRD  CONST_INT error RTHIRD 

				{
					if(table.Look_current($1->getname())!=NULL) {
								fprintf(logout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$1->getname().c_str());
								fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$1->getname().c_str());
								err++;
					}
					else {
					SymbolInfo *t=new SymbolInfo($1->getname()+"["+$3->getname()+"]","ARRAY");
					t->setvarsize(std::stoi($3->getname()));
					to_be_inserted_dl.push_back(t);
					}
				
					SymbolInfo *temp=new SymbolInfo($1->getname()+"["+$3->getname()+"]","ARRAY");
					temp->setvarsize(std::stoi($3->getname()));
					dl.push_back(temp);
				}

				| ID LTHIRD CONST_INT RTHIRD 
				{
					if(table.Look_current($1->getname())!=NULL) {
								fprintf(logout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$1->getname().c_str());
								fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$1->getname().c_str());
								err++;
					}
					else {
					SymbolInfo *t=new SymbolInfo($1->getname()+"["+$3->getname()+"]","ARRAY");
					t->setvarsize(std::stoi($3->getname()));
					t->setvarid($1->getname()+inttostring(table.getcurrent()->getnewid()));
					to_be_inserted_dl.push_back(t);
					}
					$1->setvarid($1->getname()+inttostring(table.getcurrent()->getnewid()));
					$1->settype("ARRAY");
				
					SymbolInfo *temp=new SymbolInfo($1->getname()+"["+$3->getname()+"]","ARRAY");
					temp->setvarsize(std::stoi($3->getname()));
					dl.push_back(temp);
					fprintf(logout,"Line %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
					fprintf(logout,"%s[%s]",$1->getname().c_str(),$3->getname().c_str());
					fprintf(logout,"\n\n");
					
				}

				
				| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD 
				{
					if(table.Look_current($3->getname())!=NULL) {
								fprintf(logout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$3->getname().c_str());
								fprintf(errorout,"Error at line %d: Multiple declaration of %s\n\n",line_count,$3->getname().c_str());
								err++;
					}
					else {
						SymbolInfo *t=new SymbolInfo($3->getname()+"["+$5->getname()+"]","ARRAY");
						t->setvarsize(std::stoi($5->getname()));
						t->setvarid($3->getname()+inttostring(table.getcurrent()->getnewid()));
						to_be_inserted_dl.push_back(t);
					}
					$3->setvarid($3->getname()+inttostring(table.getcurrent()->getnewid()));
					$3->settype("ARRAY");
					fprintf(logout,"Line %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
					for(int i=0;i<dl.size();i++) {
					fprintf(logout,"%s,",dl[i]->getname().c_str());
					}
				fprintf(logout,"%s[%s]",$3->getname().c_str(),$5->getname().c_str());
				fprintf(logout,"\n\n");
				SymbolInfo *temp=new SymbolInfo($3->getname()+"["+$5->getname()+"]","ARRAY");
				temp->setvarsize(std::stoi($5->getname()));
				dl.push_back(temp);
				}
				
				| declaration_list error 
				{

				}

 		  		;


argument_list : arguments 
			  {
			  $$=new SymbolInfo($1->getname(),"ARGUMENTLIST");
			  fprintf(logout,"Line %d: argument_list : arguments\n\n",line_count);
			  fprintf(logout,"%s",$1->getname().c_str());
			  fprintf(logout,"\n\n");
			  $$->setcode($1->getcode());
			  //cout<<$$->getcode()<<endl;
			  }

			  | {
			  $$=new SymbolInfo("","ARGUMENTLIST");
			  fprintf(logout,"Line %d: argument_list : Empty production\n\n\n",line_count);
			  //fprintf(logout," ");
			  //fprintf(logout,"\n");
			  }

			  ;
	

arguments : arguments COMMA logic_expression 
			{
			  $$=new SymbolInfo($1->getname()+","+$3->getname(),"ARGUMENTS");
			  fprintf(logout,"Line %d: arguments : arguments COMMA logic_expression\n\n",line_count);
			  if($3->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++; 
			  }
			  fprintf(logout,"%s,%s",$1->getname().c_str(),$3->getname().c_str());
			  fprintf(logout,"\n\n");
			  al.push_back(std::make_pair($3->getvartype(),$3->getname()));
			  $$->setcode($1->getcode()+$3->getcode());
			  
			  current_arg_list.push_back($3->getvarid());
			}
		  
	      | logic_expression
		    {
			  $$=new SymbolInfo($1->getname(),"ARGUMENTS");
			  fprintf(logout,"Line %d: arguments : logic_expression\n\n",line_count);
			  if($1->getvartype()=="void") {
				fprintf(logout,"Error at line %d: Void function called within expression\n\n",line_count);
				fprintf(errorout,"Error at line %d: Void function called within expression\n\n",line_count);
				err++; 
			  }
			  fprintf(logout,"%s",$1->getname().c_str());
			  fprintf(logout,"\n\n");
			  al.push_back(std::make_pair($1->getvartype(),$1->getname()));	
			  $$->setcode($1->getcode());
			  current_arg_list.push_back($1->getvarid());
		    }

	      ;	  


%%
int main(int argc,char *argv[])
{

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
    FILE *fin=fopen(argv[1],"r");
    if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	//logout= fopen("1705029_log.txt","w");
	//errorout= fopen("1705029_error.txt","w");

	yyin=fin;
	yyparse();
	
	fclose(fin);
	fclose(logout);
	fclose(errorout);
	//fclose(fp2);
	//fclose(fp3);
	
	return 0;
}

