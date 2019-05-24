# Temporary `if` due to `opensuse-leap-15` bug re: `service`
if os[:name] == 'suse'
  puts "[Skip `service`-based tests due to `opensuse-leap-15` detection bug (see https://github.com/inspec/train/issues/377)]"
else

  control 'OpenVPN service' do
    impact 0.5
    title 'should be running and enabled'

    # single service
    if os[:name] == 'centos' and os[:release].start_with?('6')
        describe service("openvpn") do
          it { should be_enabled }
          it { should be_running }
        end

    # multiple services
    else
      %w(server client).each do |role|
        describe service("openvpn@my#{role}1.service") do
          it { should be_enabled }
          it { should be_running }
        end
      end
    end

    %w(server client).each do |role|
      logfile = "/var/log/openvpn/my#{role}1.log"

      describe command("sh -c 'for i in $(seq 1 60); do if grep \"Initialization Sequence Completed\" #{logfile}; then exit 0; fi; echo -n '.'; sleep 1; done; cat #{logfile}; exit 1'") do
        its('exit_status') { should be 0 }
        its('stdout') { should include "Initialization Sequence Completed" }
      end
    end
  end

end
