//+------------------------------------------------------------------+
//|                                                         MACD.mq5 |
//|                                                  Rafael Fenerick |
//|                           https://www.youtube.com/RafaelFenerick |
//|                                    rafaelfenerick.mql5@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rafael Fenerick"
#property link      "rafaelfenerick.mql5@gmail.com"
#property version   "1.00"

// Inclusão de bibliotecas utilizadas
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>

input group              "Configurações gerais"
input ulong              Magic          = 123456;      // Número mágico
input group              "Configurações operacionais"
input double             SL             = 0.0;         // Stop Loss
input double             TP             = 0.0;         // Take Profit
input double             Volume         = 1;           // Volume
input group              "Configurações do indicador"
input int                EMARapida      = 12;          // EMA Rápida
input int                EMALenta       = 26;          // EMA Lenta
input int                MACD           = 9;           // MACD SMA
input ENUM_APPLIED_PRICE Preco          = PRICE_CLOSE; // Preço Aplicado
input group              "Configurações de horários"
input string             inicio         = "09:00";     // Horário de Início (entradas)
input string             termino        = "17:00";     // Horário de Término (entradas)
input string             fechamento     = "17:30";     // Horário de Fechamento (posições)

int         handle;
string      shortname;

CTrade      negocio; // Classe responsável pela execução de negócios
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
     
// Definição de número mágico
   negocio.SetExpertMagicNumber(Magic);

// Criação dos manipulador
   handle = iMACD(_Symbol, _Period, EMARapida, EMALenta, MACD, Preco);

// Verificação do resultado da criação dos manipuladores
   if(handle == INVALID_HANDLE)
     {
      Print("Erro na criação dos manipuladores");
      return INIT_FAILED;
     }

   if(!ChartIndicatorAdd(0, 1, handle))
     {
      Print("Erro na adição do indicador ao gráfico");
      return INIT_FAILED;
     }
     
   shortname = ChartIndicatorName(0, 1, ChartIndicatorsTotal(0, 1)-1);
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
   ChartIndicatorDelete(0, 1, shortname);
   
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
         int resultado = Sinal();

         // Estratégia indicou compra
         if(resultado  == 1)
            Compra();
         // Estratégia indicou venda
         if(resultado  == -1)
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
   double price = simbolo.Ask();
   double stoploss = simbolo.NormalizePrice(price - SL); // Cálculo normalizado do stoploss
   double takeprofit = simbolo.NormalizePrice(price + TP); // Cálculo normalizado do takeprofit
   negocio.Buy(Volume, NULL, price, stoploss, takeprofit, "Compra"); // Envio da ordem de compra pela classe responsável
  }
//+------------------------------------------------------------------+
//| Realizar venda com parâmetros especificados por input            |
//+------------------------------------------------------------------+
void Venda()
  {
   double price = simbolo.Bid();
   double stoploss = simbolo.NormalizePrice(price + SL); // Cálculo normalizado do stoploss
   double takeprofit = simbolo.NormalizePrice(price - TP); // Cálculo normalizado do takeprofit
   negocio.Sell(Volume, NULL, price, stoploss, takeprofit, "Venda"); // Envio da ordem de compra pela classe responsável
  }
//+------------------------------------------------------------------+
//| Fechar posição aberta                                            |
//+------------------------------------------------------------------+
void Fechar()
  {
// Verificação de posição aberta
   int total = PositionsTotal();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=Magic)
         continue;
      negocio.PositionClose(ticket);
     }
  }
//+------------------------------------------------------------------+
//| Verificar se há posição aberta                                   |
//+------------------------------------------------------------------+
bool SemPosicao()
  {
   int total = PositionsTotal();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=Magic)
         continue;
      return false;
     }
     
   return true;
  }
//+------------------------------------------------------------------+
//| Estratégia                                                       |
//+------------------------------------------------------------------+
int Sinal()
  {
   double macd[];
   ArraySetAsSeries(macd, true);
   CopyBuffer(handle, 0, 1, 2, macd);
   
   if(macd[1] <= 0 && macd[0] > 0)
      return 1;
   if(macd[1] >= 0 && macd[0] < 0)
      return -1;
   
   return 0;
  }
//+------------------------------------------------------------------+
