
#property copyright "Copyright @ Rita Lasker"
#property link      "www.ritalasker.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

int gi_76 = 20000;
int gi_80 = 55;
string gs_84 = "2011.10.26";
int gi_92 = 31;
double g_ibuf_96[];
double g_ibuf_100[];
bool gi_104;
bool gi_108;
bool gi_112 = TRUE;

int init() {
   gi_112 = TRUE;
   SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 3, Red);
   SetIndexBuffer(0, g_ibuf_96);
   SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 3, Blue);
   SetIndexBuffer(1, g_ibuf_100);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double low_44;
   double high_52;
   double lda_92[10000][3];
   string ls_unused_96;
   if (!gi_112) return (0);
   
   int ind_counted_8 = IndicatorCounted();
   int li_20 = 0;
   int li_16 = 0;
   int index_24 = 0;
   double high_60 = High[gi_76];
   double low_68 = Low[gi_76];
   int li_32 = gi_76;
   int li_36 = gi_76;
   for (int li_12 = gi_76; li_12 >= 0; li_12--) {
      low_44 = 10000000;
      high_52 = -100000000;
      for (int li_28 = li_12 + gi_80; li_28 >= li_12 + 1; li_28--) {
         if (Low[li_28] < low_44) low_44 = Low[li_28];
         if (High[li_28] > high_52) high_52 = High[li_28];
      }
      if (Low[li_12] < low_44 && High[li_12] > high_52) {
         li_16 = 2;
         if (li_20 == 1) li_32 = li_12 + 1;
         if (li_20 == -1) li_36 = li_12 + 1;
      } else {
         if (Low[li_12] < low_44) li_16 = -1;
         if (High[li_12] > high_52) li_16 = 1;
      }
      if (li_16 != li_20 && li_20 != 0) {
         if (li_16 == 2) {
            li_16 = -li_20;
            high_60 = High[li_12];
            low_68 = Low[li_12];
            gi_104 = FALSE;
            gi_108 = FALSE;
         }
         index_24++;
         if (li_16 == 1) {
            lda_92[index_24][1] = li_36;
            lda_92[index_24][2] = low_68;
            gi_104 = FALSE;
            gi_108 = TRUE;
         }
         if (li_16 == -1) {
            lda_92[index_24][1] = li_32;
            lda_92[index_24][2] = high_60;
            gi_104 = TRUE;
            gi_108 = FALSE;
         }
         high_60 = High[li_12];
         low_68 = Low[li_12];
      }
      if (li_16 == 1) {
         if (High[li_12] >= high_60) {
            high_60 = High[li_12];
            li_32 = li_12;
         }
      }
      if (li_16 == -1) {
         if (Low[li_12] <= low_68) {
            low_68 = Low[li_12];
            li_36 = li_12;
         }
      }
      li_20 = li_16;
      if (gi_108 == TRUE) {
         g_ibuf_100[li_12] = 1;
         g_ibuf_96[li_12] = 0;
      }
      if (gi_104 == TRUE) {
         g_ibuf_100[li_12] = 0;
         g_ibuf_96[li_12] = 1;
      }
   }
   return (0);
}