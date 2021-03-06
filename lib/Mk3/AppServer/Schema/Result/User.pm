package Mk3::AppServer::Schema::Result::User;

use String::Random;

use DBIx::Class::Candy
  -autotable => v1,
  -components => [ 'PassphraseColumn' ];

primary_column id => {
  data_type => 'int',
  is_auto_increment => 1,
};

unique_column username => {
  data_type => 'varchar',
  size => 255,
};

unique_column lc_username => {
  data_type => 'varchar',
  size => 255,
};

unique_column email => {
  data_type => 'varchar',
  size => 255,
};

column password => {
  data_type => 'varchar',
  size => 100,
  passphrase => 'crypt',
  passphrase_class => 'BlowfishCrypt',
  passphrase_args => {
    salt_random => 20,
    cost => 8,
  },
  passphrase_check_method => 'check_password',
};

column set_password_code => {
  data_type   => 'varchar',
  size        => 80,
  is_nullable => 1,
};

has_many( 'projects' => 'Mk3::AppServer::Schema::Result::Project', 'user_id' );
has_many( 'user_roles' => 'Mk3::AppServer::Schema::Result::UserRole', 'user_id' );
many_to_many( 'roles' => 'user_roles', 'role' );

sub set_new_password {
  my ( $self, $new_password ) = @_;

  $self->set_password_code(undef);
  $self->password( $new_password );
  $self->update;

  return $self;
}

sub create_password_code {
  my ( $self ) = @_;

  my $code = String::Random::random_regex('\w{80}');

  $self->set_password_code( $code );
  $self->update;

  return $code;
}

1;
