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


output_file = "TME_Composition_Barplot.pdf"
plt.savefig(output_file, dpi=300, bbox_inches='tight')

print(f"Grafico salvato con successo come {output_file}")
