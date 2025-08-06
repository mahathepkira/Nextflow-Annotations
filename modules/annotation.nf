
include './nbt/utils'

process ANN_snpEff {

  tag { "${vcfgz}" }

  publishDir "${outputPrefixPath(params, task)}"
  publishDir "${s3OutputPrefixPath(params, task)}"

  input:
  file(vcfgz)

  output:
  file("*ann.vcf.gz")
  file("*summary.genes.txt")
  file("*summary.html")

  script:
  
  prefix=vcfgz.simpleName
  """
  
  snpEff -Xmx16g -nodownload -c ${params.snpEff_config} -dataDir ${params.db} -v ${params.species} ${vcfgz} -stats ${prefix}_summary.html| bgzip -c > ${prefix}.ann.vcf.gz  
  
  """
}


process ANN_SnpSift {

  tag "${vcf_ann}"
  
  publishDir "${outputPrefixPath(params, task)}"
  publishDir "${s3OutputPrefixPath(params, task)}"

  input:
  file(vcf_ann)

  output:
  path "*"

  script:

  prefix=vcf_ann.simpleName

  """
  zcat ${vcf_ann} | snpSift filter "(QUAL>=50)" > ${prefix}_SnpSift.vcf
  bgzip ${prefix}_SnpSift.vcf
  """
}
