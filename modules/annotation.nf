
include './nbt/utils'

process ANN_snpEff {

  tag { "${vcfgz}" }

  publishDir "${outputPrefixPath(params, task)}"
  publishDir "${s3OutputPrefixPath(params, task)}"

  input:
  file(vcfgz)
  val extraOpts

  output:
  file("*ann.vcf.gz")
  file("*summary.genes.txt")
  file("*summary.html")
  file("*summary.csv")

  script:
  
  prefix=vcfgz.simpleName
  """
  
  snpEff -Xmx16g ${extraOpts} -dataDir /nbt_main/home/lattapol/nextflow-annotatons/bin/data -c /nbt_main/home/lattapol/nextflow-annotatons/bin/snpEff.config -v ${params.species} ${vcfgz} -stats ${prefix}_summary.html -csvStats ${prefix}_summary.csv | bgzip -c > ${prefix}.ann.vcf.gz  
  
  """
}


process BuildCustomDB {

  tag { "${params.species}" }
  
  publishDir "${outputPrefixPath(params, task)}"
  publishDir "${s3OutputPrefixPath(params, task)}"

  input:
  path fasta
  path gff

  output:
  file("snpeff_build.log")


  script:
 
  """
  mkdir -p /nbt_main/home/lattapol/nextflow-annotatons/bin/data/${params.species}
  cp ${fasta}  /nbt_main/home/lattapol/nextflow-annotatons/bin/data/${params.species}/sequences.fa
  cp ${gff}  /nbt_main/home/lattapol/nextflow-annotatons/bin/data/${params.species}/genes.gff

  echo "${params.species}.genome : ${params.species}" >> /nbt_main/home/lattapol/nextflow-annotatons/bin/snpEff.config

  snpEff build -gff3 -v ${params.species} -noCheckCds -noCheckProtein -dataDir /nbt_main/home/lattapol/nextflow-annotatons/bin/data -c /nbt_main/home/lattapol/nextflow-annotatons/bin/snpEff.config > snpeff_build.log
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
  zcat ${vcf_ann} | snpSift filter "(QUAL>=${params.SnpSift_snpsQuality})" > ${prefix}_SnpSift.vcf
  bgzip ${prefix}_SnpSift.vcf
  """
}
