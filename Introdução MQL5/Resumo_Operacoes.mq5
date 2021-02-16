//+------------------------------------------------------------------+
//|                                             Resumo_Operacoes.mq5 |
//|                                  Copyright 2017, Rafael Fenerick |
//|                           https://www.youtube.com/RafaelFenerick |
//|                                    rafaelfenerick.mql5@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Rafael Fenerick"
#property link      "rafaelfenerick.mql5@gmail.com"
#property version   "1.00"

/*
Este script exibe no gráfico informações sobre as operações 
realizadas no dia corrente.
*/

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   //Declaração de Variáveis
   datetime inicio, fim;
   double lucro = 0, perda = 0;
   int trades = 0;
   double resultado;
   ulong ticket;
   
   
   //Obtenção do Histórico
   MqlDateTime inicio_struct;
   fim = TimeCurrent(inicio_struct);
   inicio_struct.hour = 0;
   inicio_struct.min = 0;
   inicio_struct.sec = 0;
   inicio = StructToTime(inicio_struct);
   
   HistorySelect(inicio, fim);
   
   //Cálculos
   for(int i=0; i<HistoryDealsTotal(); i++)
   {
      ticket = HistoryDealGetTicket(i);
      if(ticket > 0)
      {
         if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol)
         {
            trades++;
            resultado = HistoryDealGetDouble(ticket, DEAL_PROFIT);
            if(resultado < 0)
            {
               perda += -resultado;
            }
            else
            {
               lucro += resultado;
            }
         }
      }
      
   }
   double fator_lucro;
   if(perda > 0)
   {
      fator_lucro = lucro/perda;
   }
   else
      fator_lucro = -1;
      
   double resultado_liquido = lucro - perda;
   
   
   //Exibição
   Comment("Trades: ", trades, " Lucro: ", DoubleToString(lucro, 2), " Perdas: ", DoubleToString(perda, 2), 
   " Resultado: ", DoubleToString(resultado_liquido, 2), " FL: ", DoubleToString(fator_lucro, 2));
  }
//+------------------------------------------------------------------+
