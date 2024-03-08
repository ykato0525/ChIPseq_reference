#!/bin/bash

echo "解析を開始します"
date

# 各ファイルに対するループ
for sample in /work/NGS/ChIP_sample/*.fastq.bz2
do
    # ファイル名からサンプル名を抽出
    sample_name=$(basename "$sample" .fastq.bz2)

    # bowtie2のマッピング
    bowtie2 -x /work/NGS/Reference/bowtie_index/GRCh38 -U "$sample" -S "${sample_name}.sam" > "bowtie_log_${sample_name}.txt" 2>&1

    # BAMファイルの作成
    grep -v "XS:" "${sample_name}.sam" > "${sample_name}_uniq.sam"
    samtools view -bS "${sample_name}_uniq.sam" > "${sample_name}.bam"
    samtools sort -T "${sample_name}.sort" -o "${sample_name}.sort.bam" "${sample_name}.bam"
    samtools index "${sample_name}.sort.bam"

    # ディレクトリを作成
    mkdir -p macs

    # macsでピークの確認
    # 注意: control.sort.bamは対応するコントロールサンプルを指定する必要があります
    macs callpeak -t "${sample_name}.sort.bam" -c control.sort.bam -f BAM -n "${sample_name}" -g hs --bdg --outdir macs
done

echo "解析が終了しています"
date
