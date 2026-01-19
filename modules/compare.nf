
include './nbt/utils'


process Compare_vcf {

  tag { "${vcfgz}" }

  publishDir "${outputPrefixPath(params, task)}"
  publishDir "${s3OutputPrefixPath(params, task)}"

  input:
  file(vcfgz)

  output:
  file("${prefix}_overlap.vcf.gz")
  file("${prefix}_unique.vcf.gz")

  script:

  prefix=vcfgz.simpleName
  """
  tabix ${vcfgz}
  bcftools isec ${params.vcf_compare} ${vcfgz} -n=2 -w2 -Oz -o ${prefix}_overlap.vcf.gz
  bcftools isec ${params.vcf_compare} ${vcfgz} -n=1 -w2 -Oz -o ${prefix}_unique.vcf.gz

  """
}

process Call_ANN {

  tag "${vcfgz}"
  
  publishDir "${outputPrefixPath(params, task)}"
  publishDir "${s3OutputPrefixPath(params, task)}"
 
  input:
  file(vcfgz)

  output:
  file("*.vcf.gz")

  script:

  prefix=vcfgz.simpleName

  """
  #tabix ${params.vcf_compare}
  tabix ${vcfgz}
  bcftools annotate -a ${params.vcf_compare} -c CHROM,POS,REF,ALT,INFO/ANN -Oz -o ${prefix}_shared.vcf.gz ${vcfgz}
  """
}

process Combine_VCF {

  tag "${vcfgz1}"
  
  publishDir "${outputPrefixPath(params, task)}"
  publishDir "${s3OutputPrefixPath(params, task)}"

  input:
  file(vcfgz1)
  file(vcfgz2)

  output:
  file("${prefix}_combined.sorted.vcf.gz")

  script:

  prefix=vcfgz1.simpleName

  """
  tabix ${vcfgz1}
  bcftools sort -Oz -o ${vcfgz1}.sorted.vcf.gz ${vcfgz1}
  tabix ${vcfgz2}
  bcftools sort -Oz -o ${vcfgz2}.sorted.vcf.gz ${vcfgz2}
  tabix ${vcfgz1}.sorted.vcf.gz
  tabix ${vcfgz2}.sorted.vcf.gz
  bcftools concat -a -Oz -o ${prefix}_combined.vcf.gz ${vcfgz1}.sorted.vcf.gz ${vcfgz2}.sorted.vcf.gz
  bcftools sort -Oz -o ${prefix}_combined.sorted.vcf.gz ${prefix}_combined.vcf.gz 
  """
}


