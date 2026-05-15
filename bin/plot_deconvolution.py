#!/usr/bin/env python3
import sys
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

input_excel = sys.argv[1]

print(f"Lettura dei risultati da {input_excel}...")
df = pd.read_excel(input_excel, index_col=0)
df_t = df.T

print("Generazione dello Stacked Barplot...")
fig, ax = plt.subplots(figsize=(12, 8))
df_t.plot(kind='bar', stacked=True, ax=ax, colormap='tab20', width=0.8)
plt.legend(title='Cell Types (ImmuCellAI v2)', bbox_to_anchor=(1.02, 1), loc='upper left', fontsize=8, ncol=2)
plt.title("Tumor Microenvironment (TME) Cellular Composition", fontsize=16, fontweight='bold', pad=20)
plt.ylabel("Relative Abundance (Fraction)", fontsize=12, fontweight='bold')
plt.xlabel("Samples", fontsize=12, fontweight='bold')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig("TME_Stacked_Barplot.pdf", dpi=300, bbox_inches='tight')
plt.close()

#PLOT 2
sns.set(font_scale=0.7)
g = sns.clustermap(df, cmap="YlGnBu", figsize=(12, 15), standard_scale=1, method='ward')
g.ax_heatmap.set_title("Clustered TME Profile (Standardized)", fontsize=15, fontweight='bold', pad=40)
plt.savefig("TME_Clustered_Heatmap.pdf", dpi=300, bbox_inches='tight')
plt.close()

#PLOT3
print("Generazione Correlation Matrix...")
# Calcola la correlazione tra i diversi tipi cellulari
corr = df_t.corr()
plt.figure(figsize=(12, 10))
# Plot con cerchi/quadrati per vedere quali cellule correlano tra loro
sns.heatmap(corr, cmap="RdBu_r", center=0, square=True, linewidths=.5, cbar_kws={"shrink": .5})
plt.title("Cell-Type Correlation Matrix", fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig("TME_Cell_Correlation.pdf", dpi=300, bbox_inches='tight')
plt.close()

#PLOT4
print("Generazione Boxplot...")
# Trasformiamo i dati per Seaborn
df_melted = df.reset_index().melt(id_vars='index')
df_melted.columns = ['CellType', 'Sample', 'Fraction']
plt.figure(figsize=(15, 8))
sns.boxplot(data=df_melted, x='CellType', y='Fraction', palette='viridis')
plt.xticks(rotation=90, fontsize=8)
plt.title("Cell Type Distribution across all samples", fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig("TME_Abundance_Boxplot.pdf", dpi=300, bbox_inches='tight')
plt.close()
