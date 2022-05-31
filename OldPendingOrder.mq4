//+------------------------------------------------------------------+
//|                                                 PendingOrder.mq4 |
//|                                                     Hamza Shafiq |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hamza Shafiq"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICNUM  20131111


input double PointDiffernce = 2;
input double TotalOrder     = 10;
input double StopLoss       =0.50;
extern bool removeFromThisChartOnly = true;
long ChartColor;
string LastLine2;
string BackgroundName;
int TotalGBuyOrder=0;
int TotalGSellOrder=0;
int TotalGPBuyOrder=0;
int TotalGPSellOrder=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {


   ChartColor=ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
   BackgroundName="Background-"+WindowExpertName();
   ChartBackground(BackgroundName,(color)ChartColor,0,15,300,80);
   LastLine2="Hamza Trading Boot";
   ObjectCreate("LastLine2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("LastLine2", OBJPROP_CORNER,0);
   ObjectSet("LastLine2", OBJPROP_XDISTANCE,60);
   ObjectSet("LastLine2", OBJPROP_YDISTANCE,20);
   ObjectSetText("LastLine2",LastLine2,14,"Tohoma",White);
   EventSetTimer(10);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartBackground(string StringName,color ImageColor,int Xposition,int Yposition,int Xsize,int Ysize)
  {
//---------------------------------------------------------------------
   if(ObjectFind(0,StringName)==-1)
     {
      ObjectCreate(0,StringName,OBJ_RECTANGLE_LABEL,0,0,0,0,0);
      ObjectSetInteger(0,StringName,OBJPROP_XDISTANCE,Xposition);
      ObjectSetInteger(0,StringName,OBJPROP_YDISTANCE,Yposition);
      ObjectSetInteger(0,StringName,OBJPROP_XSIZE,Xsize);
      ObjectSetInteger(0,StringName,OBJPROP_YSIZE,Ysize);
      ObjectSetInteger(0,StringName,OBJPROP_BGCOLOR,Green);
      ObjectSetInteger(0,StringName,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,StringName,OBJPROP_BORDER_COLOR,Purple);
      ObjectSetInteger(0,StringName,OBJPROP_BACK,false);
      ObjectSetInteger(0,StringName,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,StringName,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,StringName,OBJPROP_HIDDEN,false);
      ObjectSetInteger(0,StringName,OBJPROP_ZORDER,0);
     }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int differnce=0;
int stopeLoss=0;
void OnTick()
  {

   if(OrdersTotal()<TotalOrder)
     {

      bool res;
      differnce=PointDiffernce+differnce;
      stopeLoss=differnce-stopeLoss;
      //--- create timer
      res=OrderSend(Symbol(),OP_BUYSTOP,0.01,(Ask+differnce),0,NULL,NULL);
      res=OrderSend(Symbol(),OP_SELLSTOP,0.01,(Ask-differnce),0,NULL,NULL);
      if(!res)
         Print("Error in OrderModify. Error code=",GetLastError());
      else
         Print("Order modified successfully.");
     }
   CheckOpenOrders();

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void CheckOpenOrders()
  {
   int totalSell=0;
   int totalBuy=0;
   int totalPSell=0;
   int totalPBuy=0;
   selldiffernce=0;
   buydiffernce=0;
// We need to scan all the open and pending orders to see if there are any.
// OrdersTotal returns the total number of market and pending orders.
// What we do is scan all orders and check if they are of the same symbol as the one where the EA is running.
   for(int i = 0 ; i < OrdersTotal() ; i++)
     {
     
      // We select the order of index i selecting by position and from the pool of market/pending trades.
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if((TotalGBuyOrder+TotalGSellOrder)==TotalOrder)
           {
            differnce=0;
            RemoveAllOrders();
           }
      // If the pair of the order is equal to the pair where the EA is running.
      if(OrderType()==OP_BUY)
        {
         totalBuy=totalBuy+1;

        }
      if(OrderType()==OP_SELL)
        {
         totalSell=totalSell+1;

        }
      if(OrderType()==OP_BUYSTOP)
        {
         totalPBuy=totalPBuy+1;
         ModifyOrderForBuyStop(OrderTicket());
        }
      if(OrderType()==OP_SELLSTOP)
        {
         totalPSell=totalPSell+1;
         ModifyOrderForSellStop(OrderTicket());
        }
     }
   TotalGBuyOrder=totalBuy;
   TotalGSellOrder=totalSell;
   TotalGPBuyOrder=totalPBuy;
   TotalGPSellOrder=totalPSell;
   ShowOrderInBlock();

// If the loop finishes it mean there were no open orders for that pair.
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int selldiffernce=0;
void ModifyOrderForSellStop(int currentOrderTicket)
  {
   selldiffernce=selldiffernce+PointDiffernce;
   if(OrderOpenPrice()+selldiffernce<(Ask-selldiffernce))
     {
      OrderSelect(currentOrderTicket, SELECT_BY_TICKET);
      OrderModify(currentOrderTicket,(Ask-selldiffernce),NULL,NULL,0,Red);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+d

int buydiffernce=0;
void ModifyOrderForBuyStop(int currentOrderTicket)
  {
   buydiffernce=buydiffernce+PointDiffernce;
   if(OrderOpenPrice()-buydiffernce>(Ask+buydiffernce))
     {
      OrderSelect(currentOrderTicket, SELECT_BY_TICKET);
      OrderModify(currentOrderTicket,(Ask+buydiffernce),NULL,NULL,0,Blue);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowOrderInBlock()
  {

   string txtTotalBuy="Total Buy Order = "+TotalGBuyOrder;
   ObjectCreate("txtTotalBuy", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalBuy", OBJPROP_CORNER,0);
   ObjectSet("txtTotalBuy", OBJPROP_XDISTANCE,10);
   ObjectSet("txtTotalBuy", OBJPROP_YDISTANCE,40);
   ObjectSetText("txtTotalBuy",txtTotalBuy,10,"Tohoma",White);
   string txtTotalSell="Total Sell Order = "+TotalGSellOrder;
   ObjectCreate("txtTotalSell", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalSell", OBJPROP_CORNER,0);
   ObjectSet("txtTotalSell", OBJPROP_XDISTANCE,10);
   ObjectSet("txtTotalSell", OBJPROP_YDISTANCE,57);
   ObjectSetText("txtTotalSell",txtTotalSell,10,"Tohoma",White);



   string txtTotalPBuy="Pending Buy  Order = "+TotalGPBuyOrder;
   ObjectCreate("txtTotalPBuy", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalPBuy", OBJPROP_CORNER,0);
   ObjectSet("txtTotalPBuy", OBJPROP_XDISTANCE,150);
   ObjectSet("txtTotalPBuy", OBJPROP_YDISTANCE,40);
   ObjectSetText("txtTotalPBuy",txtTotalPBuy,10,"Tohoma",White);
   string txtTotalPSell="Pending Sell  Order = "+TotalGPSellOrder;
   ObjectCreate("txtTotalPSell", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalPSell", OBJPROP_CORNER,0);
   ObjectSet("txtTotalPSell", OBJPROP_XDISTANCE,150);
   ObjectSet("txtTotalPSell", OBJPROP_YDISTANCE,57);
   ObjectSetText("txtTotalPSell",txtTotalPSell,10,"Tohoma",White);

   string txtTotalOrder="Total  Order = "+OrdersTotal();
   ObjectCreate("txtTotalOrder", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalOrder", OBJPROP_CORNER,0);
   ObjectSet("txtTotalOrder", OBJPROP_XDISTANCE,10);
   ObjectSet("txtTotalOrder", OBJPROP_YDISTANCE,75);
   ObjectSetText("txtTotalOrder",txtTotalOrder,10,"Tohoma",White);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
// RemoveAllOrders();
// differnce=0;
   CheckOpenOrders();
   Print("Timer Event");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveAllOrders()
  {
   for(int i = OrdersTotal() - 1; i >= 0 ; i--)
     {
      OrderSelect(i,SELECT_BY_POS);
      if(OrderSymbol() != Symbol() && removeFromThisChartOnly)
         continue;
      double price = MarketInfo(OrderSymbol(),MODE_ASK);
      if(OrderType() == OP_BUY)
         price = MarketInfo(OrderSymbol(),MODE_BID);
      if(OrderType() == OP_BUY || OrderType() == OP_SELL)
        {
         OrderClose(OrderTicket(), OrderLots(),price,5);
        }
      else
        {
         OrderDelete(OrderTicket());
        }
      Sleep(100);
      int error = GetLastError();
      if(error > 0)
         Print("Unanticipated error: ", error);
      RefreshRates();
     }
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
void CloseOrders()
  {
// Update the exchange rates before closing the orders.
   RefreshRates();
// Log in the terminal the total of orders, current and past.
   Print(OrdersTotal());

// Start a loop to scan all the orders.
// The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.
   for(int i = (OrdersTotal() - 1); i >= 0; i--)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
        {
         Print("ERROR - Unable to select the order - ", GetLastError());
         break;
        }

      // Create the required variables.
      // Result variable - to check if the operation is successful or not.
      bool res = false;

      // Allowed Slippage - the difference between current price and close price.
      int Slippage = 0;

      // Bid and Ask prices for the instrument of the order.
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);

      // Closing the order using the correct price depending on the type of order.
      if(OrderType() == OP_BUY)
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      else
         if(OrderType() == OP_SELL)
           {
            res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
           }

      // If there was an error, log it.
      if(res == false)
         Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
     }
  }
//+------------------------------------------------------------------+
