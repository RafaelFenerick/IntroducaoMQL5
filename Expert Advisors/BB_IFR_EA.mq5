//+------------------------------------------------------------------+
//|                                                    BB_IFR_EA.mq5 |
//|                                          Copyright 2020, CMTrade |
//|                                                 fenerickmql5.com |
//+------------------------------------------------------------------+
#property copyright "CMTrade Tecnologia LTDA"
#property link      "https://www.cmtrade.com.br"
#property version   "1.00"
//+------------------------------------------------------------------+
//|Inclusão de bibliotecas utilizadas                                |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
#include <RFYouTube/Horarios.mqh>
#include <RFYouTube/Indicadores.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group              "Configurações gerais"
input ulong              Magic          = 123456;      // Número mágico
input group              "Configurações operacionais"
input double             SL             = 0.0;         // Stop Loss
input double             TP             = 0.0;         // Take Profit
input double             Volume         = 1;           // Volume
input group              "Configurações - Bandas de Bollinger"
input ENUM_SINAL         BB_Ativo       = SINAL_NENHUM;// Ativar
input int                BB_Periodo     = 20;          // Período
input double             BB_Desvio      = 2;           // Desvio
input int                BB_Deslocamento= 0;           // Deslocar
input ENUM_APPLIED_PRICE BB_Preco       = PRICE_CLOSE; // Preço Aplicado
input group              "Configurações - IFR"
input ENUM_SINAL         IFR_Ativo      = SINAL_NENHUM;// Ativar
input int                IFR_Periodo    = 14;          // Período
input ENUM_APPLIED_PRICE IFR_Preco      = PRICE_CLOSE; // Preço Aplicado
input double             IFR_LimiteSup  = 70;          // Limite Superior
input double             IFR_LimiteInf  = 30;          // Limite Inferior
input group              "Configurações de horários"
input string             H_inicio1      = "09:00";     // Horário de Início 1 (entradas)
input string             H_termino1     = "12:00";     // Horário de Término 1 (entradas)
input string             H_inicio2      = "13:00";     // Horário de Início 2 (entradas)
input string             H_termino2     = "17:00";     // Horário de Término 2 (entradas)
input string             H_fechamento2  = "17:30";     // Horário de Fechamento (posições)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrade      negocio; // Classe responsável pela execução de negócios
CSymbolInfo simbolo; // Classe responsãvel pelos dados do ativo
CHorarios   *horario1, *horario2;
CIndicadores *indicadores;
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
   
   horario1 = new CHorarios(H_inicio1, H_termino1, ""); 
   horario2 = new CHorarios(H_inicio2, H_termino2, H_fechamento2); 
   
   indicadores = new CIndicadores();
   indicadores.BB(BB_Periodo, BB_Desvio, BB_Deslocamento, BB_Preco);
   indicadores.IFR(IFR_Periodo, IFR_Preco, IFR_LimiteInf, IFR_LimiteSup);
   indicadores.SetBB(BB_Ativo);
   indicadores.SetIFR(IFR_Ativo);
   
   indicadores.Iniciar();
   
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
   delete horario1;
   delete horario2;
   
   delete indicadores;
   
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
   if(horario1.HorarioEntrada() || horario2.HorarioEntrada())
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
   if(horario1.HorarioFechamento() || horario2.HorarioFechamento())
     {
      // EA está posicionado, fechar posição
      if(!SemPosicao())
         Fechar();
     }

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
   return indicadores.Sinal();
  }
//+------------------------------------------------------------------+
