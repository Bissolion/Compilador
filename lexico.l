%{
#include <string>
#include "y.tab.h"
%}

%option noyywrap

ESPACO [ \t]
DIGITO [0-9]
LETRA [a-zA-Z]
ID {LETRA}({LETRA}|{DIGITO}|_)*

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {DIGITO}+"."{DIGITO}+


%%

"\n"		{ linha++; }

{DELIM} 	{}

"int"       { return TK_INT; }
"float"     { return TK_FLOAT; }
"char"      { return TK_CHAR; }
"bool"      { return TK_BOOL; }

[+*-/%;=()]			{ return *yytext; }


{ID}        {
            yylval.label = std::string(yytext);
            return TK_ID;
            }

{NUM}		{
             yylval.label = std::string(yytext); 
             yylval.traducao = std::string(yytext);
             return TK_NUM; 
            }
{REAL}      {
             yylval.label = std::string(yytext);
             yylval.traducao = std::string(yytext);
             return TK_REAL;
            }

.			{ fprintf(stderr, "Caractere nao reconhecido na linha %d: %s\n", linha, yytext); }

%%
