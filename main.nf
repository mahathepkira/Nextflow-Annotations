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

   main:
     if (__params.vcf_compare != "") {
         (overlap, unique) = Compare_vcf(vcfgz)
         vcf_ann1 = Call_ANN(overlap)
         (vcf_ann2,genes,html) = ANN_snpEff(unique)
         vcf_final = Combine_VCF(vcf_ann1, vcf_ann2)
     } else {
         (vcf_final,genes,html) = ANN_snpEff(vcfgz)
     }

     if (__params.SnpSift != "") {
         vcf_final2 = ANN_SnpSift(vcf_final)
     } else {
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
  
  vcfgz = Channel.fromPath("${__params.input}/*70.vcf.gz")
  vcfgz.view()
  Annotations(vcfgz)
  
}



workflow.onComplete { handleCompleteMessage() }
workflow.onError { handleErrorMessage() }



