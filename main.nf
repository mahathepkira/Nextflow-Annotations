nextflow.preview.dsl=2
/*
================================================================================
=                           Sinonkt Style I N I T                              =
================================================================================
*/
include './modules/nbt/utils'

if (params.exportKeySchema) exit 0, printKeySchema()
if (params.exportValueSchema) exit 0, printValueSchema()

params.MAINTAINERS = [
  'Krittin Phornsiricharoenphant (oatkrittin@gmail.com)',
  'Alisa Wilantho (alisa.wil@biotec.or.th)',
  'Sujiraporn Pakchuen (sujiraporn.pak@biotec.or.th)'
]

def schema = readAvroSchema("${workflow.projectDir}/schemas/value.avsc")
__params = getDefaultThenResolveParams(schema, params)


include './modules/nbt/log' params(__params)
include helpMessage from './modules/nbt/help' params(__params)
include './modules/annotation.nf' params(__params)
include './modules/compare.nf' params(__params)

if (params.version) exit 0, workflowVersionMessage()
if (params.help) exit 0, helpMessage(schema)


/*
================================================================================
=                   Sinonkt Style Workflows definitions                        =
================================================================================
*/

workflow Annotations {
   get:
     vcfgz
     extraOpts

   main:
     if (__params.vcf_compare != "") {
         (overlap, unique) = Compare_vcf(vcfgz)
         vcf_ann1 = Call_ANN(overlap)
         (vcf_ann2,genes,html) = ANN_snpEff(unique,extraOpts)
         vcf_final = Combine_VCF(vcf_ann1, vcf_ann2)
     } else {
         (vcf_final,genes,html) = ANN_snpEff(vcfgz,extraOpts)
     }

     if (__params.SnpSift == "on") {
         vcf_final2 = ANN_SnpSift(vcf_final)
     } else if (__params.SnpSift == "off") {
         vcf_final2 = vcf_final
     }

   emit:
     vcf_final2
}



workflow Annotations_custom {
   get:
     vcfgz
     fasta
     gff

   main:
     db_done = BuildCustomDB(fasta,gff)
     db_done
         .map { it -> "-nodownload" }
         .set { extraOpts }
     if (__params.vcf_compare != "") {
         (overlap, unique) = Compare_vcf(vcfgz)
         vcf_ann1 = Call_ANN(overlap)
         (vcf_ann2,genes,html) = ANN_snpEff(unique,extra_opts)
         vcf_final = Combine_VCF(vcf_ann1, vcf_ann2)
     } else {
         (vcf_final,genes,html) = ANN_snpEff(vcfgz,extraOpts)
     }

     if (__params.SnpSift == "on") {
         vcf_final2 = ANN_SnpSift(vcf_final)
     } else if (__params.SnpSift == "off") {
         vcf_final2 = vcf_final
     }

   emit:
     vcf_final2
}




/*
================================================================================
=                           Sinonkt Style M A I N                              =
================================================================================
*/

workflow {
  println("====================")
  println(__params)
  println("====================")


  vcfgz = Channel.fromPath("${__params.input}")
  vcfgz.view()

  if (__params.mode == "default"){
  
     def snpEff_home = "/nbt_main/home/lattapol/nextflow-annotatons/bin/"
     def dbDir = "${snpEff_home}/data/${params.species}"
     def extraOpts = file(dbDir).exists() ? "-nodownload" : ""
  
     Annotations(vcfgz,extraOpts)
  }
  else if (__params.mode == "custom"){

     fasta = Channel.fromPath("${__params.fasta}")
     fasta.view()
     gff = Channel.fromPath("${__params.gff}")
     gff.view()
       
     Annotations_custom(vcfgz,fasta,gff)
  }
  
}



workflow.onComplete { handleCompleteMessage() }
workflow.onError { handleErrorMessage() }



