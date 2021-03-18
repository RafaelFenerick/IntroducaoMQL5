//+------------------------------------------------------------------+
//|                                                  Indicadores.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#resource "\\Indicators\\Examples\\BB.ex5"
#resource "\\Indicators\\Examples\\RSI.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CIndicadores
  {
protected:
   
   bool                 m_bb_ativo;
   int                  m_bb_handle;
   double               m_bb_sup_buffer[];
   double               m_bb_inf_buffer[];
   int                  m_bb_periodo;
   double               m_bb_desvio;
   int                  m_bb_deslocamento;
   ENUM_APPLIED_PRICE   m_bb_preco;
   
   bool                 m_ifr_ativo;
   int                  m_ifr_handle;
   double               m_ifr_buffer[];
   int                  m_ifr_periodo;
   ENUM_APPLIED_PRICE   m_ifr_preco;
   double               m_ifr_lim_inf;
   double               m_ifr_lim_sup;

public:
   void CIndicadores();
   void ~CIndicadores();
   
   void  SetBB(bool value)  {m_bb_ativo=value; }
   void  SetIFR(bool value) {m_ifr_ativo=value;}
   void  BB(int periodo, double desvio, int deslocamento, ENUM_APPLIED_PRICE preco);
   void  IFR(int periodo, ENUM_APPLIED_PRICE preco, double lim_inf, double lim_sup);
   
   void  Iniciar();
   
   int   Sinal();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CIndicadores::CIndicadores(void)
  {
   m_bb_ativo = false;
   m_ifr_ativo = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CIndicadores::~CIndicadores(void)
  {
  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CIndicadores::BB(int periodo,double desvio,int deslocamento,ENUM_APPLIED_PRICE preco)
  {
   m_bb_periodo = periodo;
   m_bb_desvio = desvio;
   m_bb_deslocamento = deslocamento;
   m_bb_preco = preco;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CIndicadores::IFR(int periodo,ENUM_APPLIED_PRICE preco,double lim_inf,double lim_sup)
  {
   m_ifr_periodo = periodo;
   m_ifr_preco = preco;
   m_ifr_lim_inf = lim_inf;
   m_ifr_lim_sup = lim_sup;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CIndicadores::Iniciar(void)
  {
   if(m_bb_ativo)
     {
      m_bb_handle = iCustom(_Symbol, _Period, "::Indicators\\Examples\\BB.ex5", m_bb_periodo, m_bb_deslocamento, m_bb_desvio);
      ChartIndicatorAdd(0, 0, m_bb_handle);
      ArraySetAsSeries(m_bb_inf_buffer, true);
      ArraySetAsSeries(m_bb_sup_buffer, true);
     }
   if(m_ifr_ativo)
     {
      m_ifr_handle = iCustom(_Symbol, _Period, "::Indicators\\Examples\\RSI.ex5", m_ifr_periodo);
      ChartIndicatorAdd(0, 1, m_ifr_handle);
      ArraySetAsSeries(m_ifr_buffer, true);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CIndicadores::Sinal(void)
  {
   if(m_bb_ativo)
     {
      if(CopyBuffer(m_bb_handle, 1, 0, 1, m_bb_sup_buffer)<=0)
         return 0;
      if(CopyBuffer(m_bb_handle, 2, 0, 1, m_bb_inf_buffer)<=0)
         return 0;
         
      double preco = iClose(_Symbol, _Period, 0);
      if(preco < m_bb_inf_buffer[0])
         return 1;
      if(preco > m_bb_sup_buffer[0])
         return -1;
     }
     
   if(m_ifr_ativo)
     {
      if(CopyBuffer(m_ifr_handle, 0, 0, 1, m_ifr_buffer)<=0)
         return 0;
         
      if(m_ifr_buffer[0] > m_ifr_lim_sup)
         return -1;
      if(m_ifr_buffer[0] < m_ifr_lim_inf)
         return 1;
     }  
     
   return 0;
  }
//+------------------------------------------------------------------+
