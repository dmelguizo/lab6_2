#!/usr/bin/env nextflow
params.cutoff = 0.1

process filterExp {
        input:
        path expData
        val cutoff
        output:
        path "expression_filtered.txt"
        script:
        """
        #!/usr/bin/env Rscript
        data = read.table("$expData", as.is=TRUE, header=TRUE, sep='\\t', row.names=1)
        data<-data[which(rowMeans(data) >= $cutoff),]
        write.table(data,"expression_filtered.txt", sep='\\t')
        """
}

process boxplot {
        input:
        path expData
        output:
        path "boxplot.pdf"
        script:
        """
        #!/usr/bin/env Rscript
        data<-read.table("$expData", as.is=TRUE, header=TRUE, sep='\\t', row.names=1)
        pdf("boxplot.pdf")
        par(mar = c(10, 4, 2, 2))
        boxplot(data,las=2)
        dev.off()
        """
}

workflow {
        input_file = Channel.fromPath(params.input)
        filtered_data = filterExp(input_file , params.cutoff)
        plots = boxplot(filtered_data)
}
