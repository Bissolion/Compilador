%{
#include <iostream>
#include <string>
#include <vector>

#define YYSTYPE atributos

using namespace std;

enum Tipo { T_INT, T_FLOAT, T_CHAR, T_BOOL, T_ERRO };

struct atributos
{
	string label;
	string traducao;
	Tipo tipo;
};

struct Simbolo {
	string nome;
	Tipo tipo;
};

int var_temp_qnt;
int linha = 1;
string codigo_gerado;
string celulas;
vector<Simbolo> tabela_simbolos;



int yylex(void);
void yyerror(string);
string gentempcode();

string traduzTipo(Tipo t) {
	switch(t) {
		case T_INT:		return "int";
		case T_FLOAT:	return "float";
		case T_CHAR: 	return "char";
		case T_BOOL:	return "bool";
		default: 		return "void";
	}
}

Tipo buscar_tipo(string nome) {
	for (const auto& s : tabela_simbolos){
		if (s.nome == nome) return s.tipo;
	}
	return T_ERRO;
}

void inserir_simbolo(string nome, Tipo tipo) {
	if (buscar_tipo(nome) != T_ERRO) {
		yyerror("Variavel '" + nome + "' ja declarada.");
	} else {
		tabela_simbolos.push_back({nome, tipo});
	}
}
%}

%token TK_NUM TK_ID 
%token TK_INT TK_FLOAT TK_CHAR TK_BOOL

%start S

%left '+'
%left '*'

%%

S 			: DECLARACOES E
			{
				codigo_gerado = "/*Compilador FOCA*/\n"
								"#include <stdio.h>\n"
								"int main(void) {\n";

				codigo_gerado += celulas + "\n";

				codigo_gerado += $2.traducao;

				codigo_gerado += "\treturn 0;"
							"\n}\n";
			}
			;

DECLARACOES : DECLARACOES DECLARACAO | ;

DECLARACAO : TIPO TK_ID ';' 
	{
		inserir_simbolo($2.label, $1.tipo);
		celulas += "\t" + traduzTipo($1.tipo) + " " + $2.label + ";\n";
	}
	;

TIPO : TK_INT	{ $$.tipo = T_INT;	}
     | TK_FLOAT { $$.tipo = T_FLOAT; }
	 | TK_CHAR { $$.tipo = T_CHAR; }
	 | TK_BOOL { $$.tipo = T_BOOL; }
	 ;

E 			: E '+' E
			{
				$$.tipo = ($1.tipo == T_FLOAT || $3.tipo == T_FLOAT) ? T_FLOAT : T_INT;

				$$.label = gentempcode();

				celulas += "\t" + traduzTipo($$.tipo) + " " + $$.label + ";\n";

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " + " + $3.label + ";\n";
			}
			| E '*' E
			{
				$$.tipo = ($1.tipo == T_FLOAT || $3.tipo == T_FLOAT) ? T_FLOAT : T_INT;

				$$.label = gentempcode();

				celulas += "\t" + traduzTipo($$.tipo) + " " + $$.label + ";\n";

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			| TK_NUM
			{
				$$.tipo = T_INT;
				$$.label = gentempcode();
				celulas += "\t" + traduzTipo($$.tipo) + " " + $$.label + ";\n";
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				$$.tipo = buscar_tipo($1.label);
				if ($$.tipo == T_ERRO) {
						yyerror("Variavel '" + $1.label + "' nao declarada.");
				}
				$$.label = $1.label;
				$$.traducao = "";
			}
			;

%%

#include "lex.yy.c"

int yyparse();

string gentempcode()
{
	var_temp_qnt++;
	return "t" + to_string(var_temp_qnt);
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	if (yyparse() == 0)
		cout << codigo_gerado;
	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}
