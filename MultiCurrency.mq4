//+------------------------------------------------------------------+
//|                                                MultiCurrency.mq4 |
//|                                                     Hamza Shafiq |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hamza Shafiq"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define MAGICNUM  20131111
int currentPairOrder=0;
int ticket;
string GoldPair="XAUUSDm";
string EuroPair="EURUSDm";
string JPYPair="USDJPYm";
string GBPPair="GBPUSDm";
string US30Pair="US30m";
string CADPair="USDCADm";
string NasPair="USTECm";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void start()
  {

   int GoldOrder=CalculateCurrentOrders(GoldPair);
   int EuroOrder=CalculateCurrentOrders(EuroPair);
   int US30Order=CalculateCurrentOrders(US30Pair);
   Sleep(10000);
   if(GoldOrder<1&&Symbol()==GoldPair)
     {

      TakeOrder(GoldPair);

     }
   else
      if(EuroOrder<1&&Symbol()==EuroPair)
        {

         TakeOrder(EuroPair);

        }
      else
         if(US30Order<1&&Symbol()==US30Pair)
           {

            TakeOrder(US30Pair);

           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TakeOrder(string pair)
  {
   double BidPrice = MarketInfo(pair, MODE_BID);
   double AskPrice = MarketInfo(pair, MODE_ASK);
   OrderSend(pair,OP_BUY, 0.01,AskPrice,3,(AskPrice-(20*Point)),(AskPrice+(20*Point)),"Follow Trend",MAGICNUM,0,Blue);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICNUM)
        {
         if(OrderType()==OP_BUY)
            buys++;
         if(OrderType()==OP_SELL)
            sells++;
        }
     }
//--- return orders volume
   if(buys>0)
      return(buys);
   else
      return(-sells);
  }
//+------------------------------------------------------------------+
