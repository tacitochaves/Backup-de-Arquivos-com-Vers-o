#!/usr/bin/env perl
#
# app-bkp-fwbuilder.pl
#
# Este programa deve ser utilizado para fazer backup de arquivos de configuração ou daemons com opção de versionamento.
# Os backups criados seguirão este padrão: [daemon-bkp(versao_do_backup)-data_atual], tchaves.fwb-bkp-2015-01-13
#
# Author: Tácito Chaves - 2015-01-13
# e-mail: tacitochaves@gmail.com
# skype: tacito.chaves

use strict;
use warnings;

use POSIX qw(strftime);
use File::Copy qw(copy);


# pega a data atual
my $date = strftime "%Y-%m-%d", localtime;

my $daemon_dir = "/home/chaves/scripts/project/bkp-fwbuilder/fwbuilder";
my $backup_dir = "/home/chaves/scripts/project/bkp-fwbuilder/backup";

# pega o conteúdo do diretório de backup
my $lista = list_dir( $backup_dir );

# pega a versão que deve ser criado o backup
my $versao = bkp_version( $lista );

# passa os daemons para a função de backup_fw
my $create = backup_fw( "tchaves.fwb", "tchaves.fw", $versao );

# criando os backups
for my $bin ( keys %{$create} ) {
    print "Backup Criado: $create->{$bin}\n";
    copy "$daemon_dir/$bin", "$backup_dir/$create->{$bin}";
}

sub backup_fw {
    my ( $fwb, $fw, $versao ) = @_;

    my $daemons = {};

    if ( $versao eq 0 or $versao eq 'n' ) {
        $daemons->{$fwb} = $fwb . "-bkp-" . $date;
        $daemons->{$fw} = $fw . "-bkp-" . $date;
    }
    else {
        my $nova_versao = ++$versao;
        $daemons->{$fwb} = $fwb . "-bkp$nova_versao-" . $date;
        $daemons->{$fw} = $fw . "-bkp$nova_versao-" . $date;
    }

    return $daemons;
}

# retorna a maior versão dos arquivos backupeados
sub bkp_version {
    my $self = shift;

    # pegando os arquivos de configuração do fwbuilder
    my $file = [];
    for my $l ( @{$self} ) {
        chomp $l;
        if ( $l =~ m/bkp(\d+)?-$date/ ) {
            push @$file, $l;
        }
    }
    
    # pega todas as versões dos arquivos com a data atual
    my @todas_versoes;
    my $versao;

    if ( @{$file} ) {

        for my $item ( @{$file} ) {

            if ( $item =~ m/$date/ ) {

                if ( $item =~ m/bkp(\d+)-$date/g ) {
                    push @todas_versoes, $1;
                }
                else {
                    push @todas_versoes, 1;
                }
            
            }

        }

    }
    else {
        push @todas_versoes, 0;
    }
    
    # pega a versão maior encontrada
    my @versoes_organizadas = sort { $b <=> $a } @todas_versoes;
    
    $versao = $versoes_organizadas[0];

    return $versao;
}

# retorna o conteúdo da pasta de backup
sub list_dir {
    my $dir = shift;

    opendir my $dh, $dir or die "Diretório não encontrado\n";
    my @list = readdir $dh;
    close $dh;

    my $list_dir = \@list;

    return $list_dir;
}
