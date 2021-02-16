//+------------------------------------------------------------------+
//|                                                EnvioDeOrdens.mq5 |
//|                                                  Rafael Fenerick |
//|                           https://www.youtube.com/RafaelFenerick |
//|                                    rafaelfenerick.mql5@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rafael Fenerick"
#property link      "rafaelfenerick.mql5@gmail.com"
#property version   "1.00"

/*
-> Ordem (order): Instrução de compra ou venda.
-> Negócio (deal): Negociação comercial resultado de uma ordem.
-> Posição (position): Resultado de um ou mais negócios.

-> Tipos de ordens:
   -> Ordens a mercado: Execução da ordem resulta em um negócio imediato.
      -> Buy
      -> Sell
   -> Ordens pendentes: Execução futura sob determinadas circuntâncias.
      -> BuyLimit
      -> SellLimit
      -> BuyStop
      -> SellStop
      -> BuyStopLimit
      -> SellStopLimit
   -> TakeProfit e StopLoss: Casos especiais.

-> Tipo de execução (dependente do ativo):
   -> Instant: ordem deve ser ou não aceita no preço especificado
   -> Request: execução da ordem no preço recebido como válido pelo broker
   -> Market: decisão do preço determinada pelo broker
   -> Exchange: negociações enviadas para ambientes externos
   
-> Politicas de preenchimento (dependente do ativo):
   -> Fill or Kill: todo o volume especificado deve ser executado, do contrário não é executada
   -> Immediate or Cancel: executar o máximo volume disponível e cancelar o restante
   -> Return: executar o máximo volume disponível e manter o restante em espera para execução
*/

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   //--- Estruturas de negociação
   MqlTradeRequest request;
   MqlTradeResult result;
   MqlTradeCheckResult check_result;
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check_result);
   //---
   
   //--- Preenchimento da requisição
   request.action;           // Tipo de operação de negociação 
   /*
   TRADE_ACTION_DEAL
      ->Coloca uma ordem de negociação para a transação ser executada imediatamente usando os parâmetros especificados (ordem de mercado)
   TRADE_ACTION_PENDING
      ->Coloca uma ordem de negociação para a transação ser executada sob certas condições (ordem pendente)
   TRADE_ACTION_SLTP
      ->Modifica valores de Stop-Loss e Take-Profit numa posição aberta
   TRADE_ACTION_MODIFY
      ->Modifca os parâmetros de uma ordem colocada anteriormente
   TRADE_ACTION_REMOVE
      ->Exclui uma ordem pendente colocada anteriormente
   TRADE_ACTION_CLOSE_BY
      ->Fechar a posição oposta
   */
   request.magic;            // Expert Advisor -conselheiro- ID (número mágico) 
   request.order;            // Bilhetagem da ordem 
   request.symbol;           // Símbolo de negociação 
   request.volume;           // Volume solicitado para uma encomenda em lotes 
   request.price;            // Preço 
   request.stoplimit;        // Nível StopLimit da ordem 
   request.sl;               // Nível Stop Loss da ordem 
   request.tp;               // Nível Take Profit da ordem 
   request.deviation;        // Máximo desvio possível a partir do preço requisitado 
   request.type;             // Tipo de ordem 
   /*
   ORDER_TYPE_BUY
      ->Ordem de Comprar a Mercado
   ORDER_TYPE_SELL
      ->Ordem de Vender a Mercado
   ORDER_TYPE_BUY_LIMIT
      ->Ordem pendente Buy Limit
   ORDER_TYPE_SELL_LIMIT
      ->Ordem pendente Sell Limit
   ORDER_TYPE_BUY_STOP
      ->Ordem pendente Buy Stop
   ORDER_TYPE_SELL_STOP
      ->Ordem pendente Sell Stop
   ORDER_TYPE_BUY_STOP_LIMIT
      ->Ao alcançar o preço da ordem, uma ordem pendente Buy Limit é colocada no preço StopLimit
   ORDER_TYPE_SELL_STOP_LIMIT
      ->Ao alcançar o preço da ordem, uma ordem pendente Sell Limit é colocada no preço StopLimit
   ORDER_TYPE_CLOSE_BY
      ->Ordem de fechamento da posição oposta
   */
   request.type_filling;     // Tipo de execução da ordem 
   /*
   ORDER_FILLING_FOK
   ORDER_FILLING_IOC
   ORDER_FILLING_RETURN
   */
   request.type_time;        // Tipo de expiração da ordem 
   /*
   ORDER_TIME_GTC
      ->Ordem válida até cancelamento
   ORDER_TIME_DAY
      ->Ordem válida até o final do dia corrente de negociação
   ORDER_TIME_SPECIFIED
      ->Ordem válida até expiração
   ORDER_TIME_SPECIFIED_DAY
      ->A ordem permanecerá efetiva até 23:59:59 do dia especificado. Se esta hora está fora de uma sessão de negociação, a ordem expira na hora de negociação mais próxima.
   */
   request.expiration;       // Hora de expiração da ordem (para ordens do tipo ORDER_TIME_SPECIFIED)) 
   request.comment;          // Comentário sobre a ordem 
   request.position;         // Bilhete da posição 
   request.position_by;      // Bilhete para uma posição oposta 
   //---
   
   //--- Estrutura de checagem da ordem
   check_result.retcode;             // Código da resposta 
   check_result.balance;             // Saldo após a execução da operação (deal) 
   check_result.equity;              // Saldo a mercado (equity) após a execução da operação 
   check_result.profit;              // Lucro flutuante 
   check_result.margin;              // Requerimentos de Margem 
   check_result.margin_free;         // Margem livre 
   check_result.margin_level;        // Nível de margem 
   check_result.comment;             // Comentário sobre o código da resposta (descrição do erro)
   //---
   
   //--- Estrutura de resultado da ordem
   result.retcode;          // Código de retorno da operação 
   result.deal;             // Bilhetagem (ticket) da operação (deal),se ela for realizada 
   result.order;            // Bilhetagem (ticket) da ordem, se ela for colocada 
   result.volume;           // Volume da operação (deal), confirmada pela corretora 
   result.price;            // Preço da operação (deal), se confirmada pela corretora 
   result.bid;              // Preço de Venda corrente 
   result.ask;              // Preço de Compra corrente 
   result.comment;          // Comentário da corretora para a operação (por default, ele é preenchido com a descrição código de retorno de um servidor de negociação) 
   result.request_id;       // Identificador da solicitação definida pelo terminal durante o despacho 
   result.retcode_external; // Código de resposta do sistema de negociação exterior
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
   }
   //---
   
//---
   
  }
//+------------------------------------------------------------------+
