//+------------------------------------------------------------------+
//|                                            CruzamentoMediaEA.mq5 |
//|                                                  Rafael Fenerick |
//|                           https://www.youtube.com/RafaelFenerick |
//|                                    rafaelfenerick.mql5@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rafael Fenerick"
#property link      "rafaelfenerick.mql5@gmail.com"
#property version   "1.00"

/*
EA com horário de início, término e fechamento.
Estratégia baseada no cruzamento de duas médias.
*/

// Inclusão de bibliotecas utilizadas
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>

input int      PeriodoLongo   = 20;       // Período Média Longa
input int      PeriodoCurto   = 10;       // Período Média Curta
input double   SL             = 3.0;      // Stop Loss
input double   TP             = 5.0;      // Take Profit
input double   Volume         = 5;        // Volume
input string   inicio         = "09:05";  // Horário de Início (entradas)
input string   termino        = "17:00";  // Horário de Término (entradas)
input string   fechamento     = "17:30";  // Horário de Fechamento (posições)

int handlemedialonga, handlemediacurta; // Manipuladores dos dois indicadores de média móvel

CTrade negocio; // Classe responsável pela execução de negócios
CSymbolInfo simbolo; // Classe responsãvel pelos dados do ativo

// Estruturas de tempo para manipulação de horários
MqlDateTime horario_inicio, horario_termino, horario_fechamento, horario_atual;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
   // Definição do símbolo utilizado para a classe responsável
   if(!simbolo.Name(_Symbol))
   {
      printf("Ativo Inválido!");
      return INIT_FAILED;
   }
   
   // Criação dos manipuladores com Períodos curto e longo
   handlemediacurta = iCustom(_Symbol, _Period, "MediaMovel", PeriodoCurto);
   handlemedialonga = iCustom(_Symbol, _Period, "MediaMovel", PeriodoLongo);
   
   // Verificação do resultado da criação dos manipuladores
   if(handlemediacurta == INVALID_HANDLE || handlemedialonga == INVALID_HANDLE)
   {
      Print("Erro na criação dos manipuladores");
      return INIT_FAILED;
   }
      
   // Verificação de inconsistências nos parâmetros de entrada
   if(PeriodoLongo <= PeriodoCurto)
   {
      Print("Parâmetros de médias incorretos");
      return INIT_FAILED;
   }
//---
   
   // Criação das structs de tempo
   TimeToStruct(StringToTime(inicio), horario_inicio);
   TimeToStruct(StringToTime(termino), horario_termino);
   TimeToStruct(StringToTime(fechamento), horario_fechamento);
   
   // Verificação de inconsistências nos parâmetros de entrada
   if(horario_inicio.hour > horario_termino.hour || (horario_inicio.hour == horario_termino.hour && horario_inicio.min > horario_termino.min))
   {
      printf("Parâmetros de Horário inválidos!");
      return INIT_FAILED;
   }
   
   // Verificação de inconsistências nos parâmetros de entrada
   if(horario_termino.hour > horario_fechamento.hour || (horario_termino.hour == horario_fechamento.hour && horario_termino.min > horario_fechamento.min))
   {
      printf("Parâmetros de Horário inválidos!");
      return INIT_FAILED;
   }
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   // Motivo da desinicialização do EA
   printf("Deinit reason: %d", reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   // Atualização dos dados do ativo
   if(!simbolo.RefreshRates())
      return;
   
   // EA em horário de entrada em novas operações
   if(HorarioEntrada())
   {
      // EA não está posicionado
      if(SemPosicao())
      {
         // Verificar estratégia e determinar compra ou venda
         int resultado_cruzamento = Cruzamento();
         
         // Estratégia indicou compra
         if(resultado_cruzamento == 1)
            Compra();
         // Estratégia indicou venda
         if(resultado_cruzamento == -1)
            Venda();
      }
   }
   
   // EA em horário de fechamento de posições abertas
   if(HorarioFechamento())
   {
      // EA está posicionado, fechar posição
      if(!SemPosicao())
         Fechar();
   }
   
  }
//+------------------------------------------------------------------+
//| Checar se horário atual está dentro do horário de entradas       |
//+------------------------------------------------------------------+
bool HorarioEntrada()
{
   TimeToStruct(TimeCurrent(), horario_atual); // Obtenção do horário atual
   
   // Hora dentro do horário de entradas
   if(horario_atual.hour >= horario_inicio.hour && horario_atual.hour <= horario_termino.hour)
   {
      // Hora atual igual a de início
      if(horario_atual.hour == horario_inicio.hour)
         // Se minuto atual maior ou igual ao de início => está no horário de entradas
         if(horario_atual.min >= horario_inicio.min)
            return true;
         // Do contrário não está no horário de entradas
         else
            return false;
      
      // Hora atual igual a de término
      if(horario_atual.hour == horario_termino.hour)
         // Se minuto atual menor ou igual ao de término => está no horário de entradas
         if(horario_atual.min <= horario_termino.min)
            return true;
         // Do contrário não está no horário de entradas
         else
            return false;
      
      // Hora atual maior que a de início e menor que a de término
      return true;
   }
   
   // Hora fora do horário de entradas
   return false;
}
//+------------------------------------------------------------------+
//| Checar se horário atual está dentro do horário de fechamento     |
//+------------------------------------------------------------------+
bool HorarioFechamento()
{
   TimeToStruct(TimeCurrent(), horario_atual); // Obtenção do horário atual
   
   // Hora dentro do horário de fechamento
   if(horario_atual.hour >= horario_fechamento.hour)
   {
      // Hora atual igual a de fechamento
      if(horario_atual.hour == horario_fechamento.hour)
         // Se minuto atual maior ou igual ao de fechamento => está no horário de fechamento
         if(horario_atual.min >= horario_fechamento.min)
            return true;
         // Do contrário não está no horário de fechamento
         else
            return false;
      
      // Hora atual maior que a de fechamento
      return true;
   }
   
   // Hora fora do horário de fechamento
   return false;
}
//+------------------------------------------------------------------+
//| Realizar compra com parâmetros especificados por input           |
//+------------------------------------------------------------------+
void Compra()
{
   double price = simbolo.Ask(); // Determinação do preço da ordem a mercado
   double stoploss = simbolo.NormalizePrice(price - SL); // Cálculo normalizado do stoploss
   double takeprofit = simbolo.NormalizePrice(price + TP); // Cálculo normalizado do takeprofit
   negocio.Buy(Volume, NULL, price, stoploss, takeprofit, "Compra CruzamentoMediaEA"); // Envio da ordem de compra pela classe responsável
}
//+------------------------------------------------------------------+
//| Realizar venda com parâmetros especificados por input            |
//+------------------------------------------------------------------+
void Venda()
{
   double price = simbolo.Bid(); // Determinação do preço da ordem a mercado
   double stoploss = simbolo.NormalizePrice(price + SL); // Cálculo normalizado do stoploss
   double takeprofit = simbolo.NormalizePrice(price - TP); // Cálculo normalizado do takeprofit
   negocio.Sell(Volume, NULL, price, stoploss, takeprofit, "Venda CruzamentoMediaEA"); // Envio da ordem de compra pela classe responsável
}
//+------------------------------------------------------------------+
//| Fechar posição aberta                                            |
//+------------------------------------------------------------------+
void Fechar()
{
   // Verificação de posição aberta
   if(!PositionSelect(_Symbol))
      return;
      
   long tipo = PositionGetInteger(POSITION_TYPE); // Tipo da posição aberta
   
   // Vender em caso de posição comprada
   if(tipo == POSITION_TYPE_BUY)
      negocio.Sell(Volume, NULL, 0, 0, 0, "Fechamento CruzamentoMediaEA");
   // Comprar em caso de posição vendida
   else
      negocio.Buy(Volume, NULL, 0, 0, 0, "Fechamento CruzamentoMediaEA");
}
//+------------------------------------------------------------------+
//| Verificar se há posição aberta                                   |
//+------------------------------------------------------------------+
bool SemPosicao()
{  
   return !PositionSelect(_Symbol);
}
//+------------------------------------------------------------------+
//| Estratégia de cruzamento de médias                               |
//+------------------------------------------------------------------+
int Cruzamento()
{
   // Cópia dos buffers dos indicadores de média móvel com períodos curto e longo
   double MediaCurta[], MediaLonga[];
   ArraySetAsSeries(MediaCurta, true);
   ArraySetAsSeries(MediaLonga, true);
   CopyBuffer(handlemediacurta, 0, 0, 2, MediaCurta);
   CopyBuffer(handlemedialonga, 0, 0, 2, MediaLonga);
   
   // Compra em caso de cruzamento da média curta para cima da média longa
   if(MediaCurta[1] <= MediaLonga[1] && MediaCurta[0] > MediaLonga[0])
      return 1;
   
   // Venda em caso de cruzamento da média curta para baixo da média longa
   if(MediaCurta[1] >= MediaLonga[1] && MediaCurta[0] < MediaLonga[0])
      return -1;
      
   return 0;
}
//+------------------------------------------------------------------+
