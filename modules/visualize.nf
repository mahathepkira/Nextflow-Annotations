include './nbt/utils'

process BCFtools_stats {

  tag { "${vcf}" }

  publishDir "${outputPrefixPath(params, task)}"
  publishDir "${s3OutputPrefixPath(params, task)}"

  input:
  file(vcf)

  output:
  path "*"

  script:
  prefix=vcf

  """
  tabix -p vcf ${vcf}
  bcftools stats --threads 8 ${vcf} > ${prefix}.stat
  """
}


process VCFstats {

  tag { "${vcf}" }

  publishDir "${outputPrefixPath(params, task)}"
  publishDir "${s3OutputPrefixPath(params, task)}"

  input:
  tuple val(fileId), file(vcf)

  output:
  file("*.frq")
  file("*.lmiss")
  file("*.TsTv.summary")
  file("*.summary")
  file("*_allele_frequency.csv")
  file("*_lmiss_count.csv")
  script:
  prefix=vcf.baseName

  """
  vcftools --gzvcf "$vcf" --freq --out "${prefix}"
  vcftools --gzvcf "$vcf" --missing-site --out "${prefix}"
  vcftools --gzvcf "$vcf" --TsTv-summary --out "${prefix}"
  zcat "$vcf" | vcf-annotate --fill-type | grep -oP "TYPE=\\w+" | sort | uniq -c > "${prefix}.summary"  
  python /nbt_main/home/lattapol/nextflow-Callvariants/bin/create_AF_his.py ${prefix}.frq
  python /nbt_main/home/lattapol/nextflow-Callvariants/bin/create_lmiss_his.py ${prefix}.lmiss
  """
}


process Histogram {

  tag { "${frq}" }

  publishDir "${outputPrefixPath(params, task)}"
  publishDir "${s3OutputPrefixPath(params, task)}"

  input:
  file(frq)
  file(lmiss)

  output:
  file("*.csv")
 
  script:

  """
  python /nbt_main/home/lattapol/nextflow-Callvariants/bin/create_AF_his.py ${frq}
  python /nbt_main/home/lattapol/nextflow-Callvariants/bin/create_lmiss_his.py ${lmiss}   
  """



}
