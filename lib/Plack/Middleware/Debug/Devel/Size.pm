package Plack::Middleware::Debug::Devel::Size;
use Modern::Perl;
use Plack::Util::Accessor qw(for);
use parent 'Plack::Middleware::Debug::Base';
use Devel::Size 'total_size';

our $VERSION = '0.01';

=head1 configuration

the common yaml syntax is 

plack_middlewares:
    -
      - Debug
      - panels
      -
        - Dancer::Settings
        - [Devel::Size, for,['Dancer::Route','Dancer::Session']]
        - Profiler::NYTProf

i rather prefer

    symdump: &s
        - 'Dancer::Route'
        - 'Dancer::Session'
    plack_middlewares:
        - [Debug, panels, [Dancer::Settings,[Devel::Size, for, *s ],Profiler::NYTProf] ]

or 

    plack_middlewares:
        - [Debug, panels, [Dancer::Settings,[Devel::Size, for,['Dancer::Route','Dancer::Session']],Profiler::NYTProf] ]


=cut


sub snitch {
    my $ns = shift;
    no strict 'refs';
    my $ref = \%{$ns.'::'};
    total_size $ref;
}


sub prepare_app {
    my $self = shift;
    $self->for([]) unless $self->for
}

sub run {
    require YAML;
    my ( $self, $env, $panel ) = @_;
    sub {
        my $res = shift;
        my $total = 0;
        $panel->content
        ( $self->render_list_pairs
            ( [ map { my $s = snitch $_; $total += $s; $_ => $s; } @{ $self->for } ] )
        );
        $panel->nav_subtitle($total);
    }
}

1;

