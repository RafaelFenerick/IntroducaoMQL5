//+------------------------------------------------------------------+
//|                                            CruzamentoMediaEA.mq5 |
//|                                                  Rafael Fenerick |
//|                           https://www.youtube.com/RafaelFenerick |
//|                                    rafaelfenerick.mql5@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rafael Fenerick"
#property link      "rafaelfenerick.mql5@gmail.com"
#property version   "1.10"

/*
EA com horário de início, término e fechamento.
Estratégia baseada no cruzamento de duas médias.
*/

// Inclusão de bibliotecas utilizadas
//#include <Trade/Trade.mqh> As ordens serão enviadas por meio da função OrderSend
#include <Trade/SymbolInfo.mqh>

input ENUM_TRADE_REQUEST_ACTIONS TipoAction=TRADE_ACTION_DEAL; // Tipo de Ordem Enviada
input double   Distancia      = 2.0;      // Distância da Ordem (ordens pendentes)
input int      PeriodoLongo   = 20;       // Período Média Longa
input int      PeriodoCurto   = 10;       // Período Média Curta
input double   SL             = 3.0;      // Stop Loss
input double   TP             = 5.0;      // Take Profit
input double   BE             = 3.0;      // Break Even
input double   Volume         = 5;        // Volume
input string   inicio         = "09:05";  // Horário de Início (entradas)
input string   termino        = "17:00";  // Horário de Término (entradas)
input string   fechamento     = "17:30";  // Horário de Fechamento (posições)

int handlemedialonga, handlemediacurta; // Manipuladores dos dois indicadores de média móvel

//CTrade negocio; // Classe responsável pela execução de negócios
CSymbolInfo simbolo; // Classe responsãvel pelos dados do ativo
//--- Estruturas de negociação
MqlTradeRequest request;
MqlTradeResult result;
MqlTradeCheckResult check_result;

int magic = 1234; // Número mágico das ordens

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
   
   // Checar se ordem é pendente ou a mercado e determinar trade action
   if(TipoAction!=TRADE_ACTION_DEAL && TipoAction!= TRADE_ACTION_PENDING)
   {
      printf("Tipo de ordem não permitido");
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
      if(SemPosicao() && SemOrdem())
      {
         
         ObjectDelete(0, "BE");
         
         // Verificar estratégia e determinar compra ou venda
         int resultado_cruzamento = Cruzamento();
         
         // Estratégia indicou compra
         if(resultado_cruzamento == 1)
            Compra();
         // Estratégia indicou venda
         if(resultado_cruzamento == -1)
            Venda();
      }
      // EA está posicionado
      if(!SemPosicao())
      {
         BreakEven();
      }
   }
   
   // EA em horário de fechamento de posições abertas
   if(HorarioFechamento())
   {
      // EA está posicionado, fechar posição
      if(!SemPosicao() || !SemOrdem())
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
   double price;
   if(TipoAction==TRADE_ACTION_DEAL) // Determinação do preço da ordem a mercado
      price = simbolo.Ask(); 
   else
      price = simbolo.Bid() - Distancia;
   double stoploss = simbolo.NormalizePrice(price - SL); // Cálculo normalizado do stoploss
   double takeprofit = simbolo.NormalizePrice(price + TP); // Cálculo normalizado do takeprofit
   //negocio.Buy(Volume, NULL, price, stoploss, takeprofit, "Compra CruzamentoMediaEA"); // Envio da ordem de compra pela classe responsável
   
   // Limpar informações das estruturas
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check_result);
   
   //--- Preenchimento da requisição
   request.action       =TipoAction;
   request.magic        =magic;
   request.symbol       =_Symbol;
   request.volume       =Volume;
   request.price        =price; 
   request.sl           =stoploss;
   request.tp           =takeprofit;
   if(TipoAction==TRADE_ACTION_DEAL)
      request.type      =ORDER_TYPE_BUY;
   else
      request.type      =ORDER_TYPE_BUY_LIMIT;
   request.type_filling =ORDER_FILLING_RETURN; 
   request.type_time    =ORDER_TIME_DAY;
   request.comment      ="Compra CruzamentoMediaEA";
   
   //--- Checagem e envio de ordens
   ResetLastError();
   if(!OrderCheck(request, check_result))
   {
      PrintFormat("Erro em OrderCheck: %d", GetLastError());
      PrintFormat("Código de Retorno: %d", check_result.retcode);
      return;
   }
   
   if(!OrderSend(request, result))
   {
      PrintFormat("Erro em OrderSend: %d", GetLastError());
      PrintFormat("Código de Retorno: %d", result.retcode);
      return;
   }
   
   ObjectCreate(0, "BE", OBJ_HLINE, 0, 0, price + BE);
}
//+------------------------------------------------------------------+
//| Realizar venda com parâmetros especificados por input            |
//+------------------------------------------------------------------+
void Venda()
{
   double price;
   if(TipoAction==TRADE_ACTION_DEAL) // Determinação do preço da ordem a mercado
      price = simbolo.Bid(); 
   else
      price = simbolo.Ask() + Distancia;
   double stoploss = simbolo.NormalizePrice(price + SL); // Cálculo normalizado do stoploss
   double takeprofit = simbolo.NormalizePrice(price - TP); // Cálculo normalizado do takeprofit
   //negocio.Sell(Volume, NULL, price, stoploss, takeprofit, "Venda CruzamentoMediaEA"); // Envio da ordem de compra pela classe responsável
   
   // Limpar informações das estruturas
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check_result);
   
   //--- Preenchimento da requisição
   request.action       =TipoAction;
   request.magic        =magic;
   request.symbol       =_Symbol;
   request.volume       =Volume;
   request.price        =price; 
   request.sl           =stoploss;
   request.tp           =takeprofit;
   if(TipoAction==TRADE_ACTION_DEAL)
      request.type      =ORDER_TYPE_SELL;
   else
      request.type      =ORDER_TYPE_SELL_LIMIT;
   request.type_filling =ORDER_FILLING_RETURN; 
   request.type_time    =ORDER_TIME_DAY;
   request.comment      ="Venda CruzamentoMediaEA";
   
   //--- Checagem e envio de ordens
   ResetLastError();
   if(!OrderCheck(request, check_result))
   {
      PrintFormat("Erro em OrderCheck: %d", GetLastError());
      PrintFormat("Código de Retorno: %d", check_result.retcode);
      return;
   }
   
   if(!OrderSend(request, result))
   {
      PrintFormat("Erro em OrderSend: %d", GetLastError());
      PrintFormat("Código de Retorno: %d", result.retcode);
      return;
   }
   
   ObjectCreate(0, "BE", OBJ_HLINE, 0, 0, price - BE);
}
//+------------------------------------------------------------------+
//| Fechar posição aberta                                            |
//+------------------------------------------------------------------+
void Fechar()
{  
   if(OrdersTotal() != 0)
   {
      for(int i=OrdersTotal()-1; i>=0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if(OrderGetString(ORDER_SYMBOL)==_Symbol)
         {
            ZeroMemory(request);
            ZeroMemory(result);
            ZeroMemory(check_result);
            request.action       =TRADE_ACTION_REMOVE;
            request.order        =ticket;
            
            //--- Checagem e envio de ordens
            ResetLastError();
            if(!OrderCheck(request, check_result))
            {
               PrintFormat("Erro em OrderCheck: %d", GetLastError());
               PrintFormat("Código de Retorno: %d", check_result.retcode);
               return;
            }
            
            if(!OrderSend(request, result))
            {
               PrintFormat("Erro em OrderSend: %d", GetLastError());
               PrintFormat("Código de Retorno: %d", result.retcode);
            }
         }
      }
   }
   
   // Verificação de posição aberta
   if(!PositionSelect(_Symbol))
      return;
      
   // Limpar informações das estruturas
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check_result);
   
   //--- Preenchimento da requisição
   request.action       =TRADE_ACTION_DEAL;
   request.magic        =magic;
   request.symbol       =_Symbol;
   request.volume       =Volume;
   request.type_filling =ORDER_FILLING_RETURN; 
   request.comment      ="Fechamento CruzamentoMediaEA";
      
   long tipo = PositionGetInteger(POSITION_TYPE); // Tipo da posição aberta
   
   // Vender em caso de posição comprada
   if(tipo == POSITION_TYPE_BUY)
      //negocio.Sell(Volume, NULL, 0, 0, 0, "Fechamento CruzamentoMediaEA");
   {
      request.price        =simbolo.Bid(); 
      request.type         =ORDER_TYPE_SELL;
   }
   // Comprar em caso de posição vendida
   else
      //negocio.Buy(Volume, NULL, 0, 0, 0, "Fechamento CruzamentoMediaEA");
   {
      request.price        =simbolo.Ask(); 
      request.type         =ORDER_TYPE_BUY;
   }
   
   //--- Checagem e envio de ordens
   ResetLastError();
   if(!OrderCheck(request, check_result))
   {
      PrintFormat("Erro em OrderCheck: %d", GetLastError());
      PrintFormat("Código de Retorno: %d", check_result.retcode);
      return;
   }
   
   if(!OrderSend(request, result))
   {
      PrintFormat("Erro em OrderSend: %d", GetLastError());
      PrintFormat("Código de Retorno: %d", result.retcode);
   }
}
//+------------------------------------------------------------------+
//| Verificar se há posição aberta                                   |
//+------------------------------------------------------------------+
bool SemPosicao()
{  
   bool resultado = !PositionSelect(_Symbol);
   return resultado;
}
//+------------------------------------------------------------------+
//| Verificar se há ordem aberta                                     |
//+------------------------------------------------------------------+
bool SemOrdem()
{  
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL)==_Symbol)
         return false;
   }
   return true;
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
void BreakEven()
{
   if(!PositionSelect(_Symbol))
      return;
      
   double preco_abertura = PositionGetDouble(POSITION_PRICE_OPEN);
   double delta = simbolo.Last() - preco_abertura;
   double sl = PositionGetDouble(POSITION_SL);
   
   //--- Inverter delta para posição vendida
   if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
      delta *= -1;
   
   if(sl == preco_abertura)
      return;
   
   if(delta >= BE)
   {
      //--- Estruturas de negociação
      ZeroMemory(request);
      ZeroMemory(result);
      ZeroMemory(check_result);
      //---
      
      //--- Preenchimento da requisição
      request.action = TRADE_ACTION_SLTP;                               // Tipo de operação de negociação 
      request.magic = magic;                                            // Expert Advisor -conselheiro- ID (número mágico) 
      request.symbol = _Symbol;                                         // Símbolo de negociação 
      request.sl = preco_abertura;                                      // Nível Stop Loss da ordem 
      request.tp = PositionGetDouble(POSITION_TP);                      // Nível Take Profit da ordem 
      request.position = PositionGetInteger(POSITION_TICKET);           // Bilhete da posição 
      //---
      //--- Checagem e envio de ordens
      ResetLastError();
      if(!OrderCheck(request, check_result))
      {
         PrintFormat("Erro em OrderCheck: %d", GetLastError());
         PrintFormat("Código de Retorno: %d", check_result.retcode);
         return;
      }
      
      if(!OrderSend(request, result))
      {
         PrintFormat("Erro em OrderSend: %d", GetLastError());
         PrintFormat("Código de Retorno: %d", result.retcode);
         return;
      }
      
      ObjectDelete(0, "BE");
      //---
   }
}
//+------------------------------------------------------------------+
