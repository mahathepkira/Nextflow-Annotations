# Nextflow-Annotations


## หัวข้อ
1. [บทนำ](#1-บทนำ)
2. [การใช้งาน Nextflow-Annotations](#2-การใช้งาน-Nextflow-Annotations)
3. [การเตรียมเครื่องมือและข้อมูลสำหรับ Nextflow-Annotations](#3-การเตรียมเครื่องมือและข้อมูลสำหรับ-Nextflow-Annotations)
4. [รายละเอียดขั้นตอนใน Nextflow-Annotations](#4-รายละเอียดขั้นตอนใน-Nextflow-Annotations)
5. [การปรับแต่งการ Annotations ใน VEP](#5-การปรับแต่งการ-Annotations-ใน-VEP)
6. [Output](#6-Output)

---

## 1. บทนำ
 Nextflow-Annotations เป็น bioinformatics pipline ที่พัฒนาขึ้นสำหรับการทำ Variants Annotations โดยจะมีขั้นตอนดังต่อไปนี้ 
1. การทำ Variant Annotations
2. การสร้าง Database (BuildCustomDB)
3. การเปรียบเทียบข้อมูล Variant ที่ซ้ำกับข้อมูล Variant ที่มีอยู่ (Comapare_VCF)
4. การดึงข้อมูล Variant Annotations ที่ซ้ำกับข้อมูล Variant ที่มีอยู่ (Call_ANN)
5. การรวมไฟล์ (Combine_VCF)
6. การใช่ SnpSift (ANN_SnpSift)

![ภาพ nextflow](SnpEff.drawio.png)

## 2. การใช้งาน Nextflow-Annotations
### การใช้งานแบบไม่ใช้ขั้นตอน Comapare_VCF 
ผู้ใช้งานสามารถใช้คำสั่งต่อไปนี้ในการสั่งใช้งาน Nextflow-Annotations โดยข้อมูลที่อยู่ใน data จะต้องอยู่ในรูป vcf.gz และจะต้องระบุ `--species` ที่ต้องการ Annotations โดย workflow การทำงานจะเป็นไปตามเส้นแดง

```bash
nextflow run main.nf -profile gb --input <path-data>  --species <species-samples>  --output <path-results>
```
### การใช้งานแบบใช้ขั้นตอน Compare_VCF 
ผู้ใช้งานสามารถใช้ option `--vcf_compare` ในการระบุเส้นทางของไฟล์ VCF ที่จะใช้ในการเปรียบเทียบ โดย workflow การทำงานจะเป็นไปตามเส้นเขียว

```bash
nextflow run main.nf -profile gb --input <path-data> --vcf_compare <path>/{compare}.vcf.gz --species <species-samples>  --output <path-results>
```

### การใช้งานแบบใช้การสร้าง Database เอง 
ผู้ใช้งานสามารถใช้ `--mode custom` ในการสร้าง Databese ในการ Annotations เอง ด้วยไฟล์  `fasta ` และ  `gff ` โดย workflow การทำงานจะเป็นไปตามเส้นสีน้ำเงิน ซึ่งเหมาะสำหรับในกรณีที่ผู้ใช้ต้องการทำงานกับ species ที่ไม่มีอยู่ใน snpEff 

```bash
nextflow run main.nf -profile gb --input <path-data> --mode custom --species <species-samples> --fasta <path-fasta> --gff <path-gff> --output <path-results>
```
