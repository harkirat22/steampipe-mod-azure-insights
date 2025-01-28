dashboard "network_application_gateway_detail" {

  title         = "Azure Network Application Gateway Detail"
  documentation = file("./dashboards/network/docs/network_application_gateway_detail.md")

  tags = merge(local.network_common_tags, {
    type = "Detail"
  })

  input "gateway_id" {
    title = "Select an application gateway:"
    query = query.network_application_gateway_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.network_application_gateway_sku_name
      args  = [self.input.gateway_id.value]
    }

    card {
      width = 2
      query = query.network_application_gateway_sku_tier
      args  = [self.input.gateway_id.value]
    }

    card {
      width = 2
      query = query.network_application_gateway_backend_pool_count
      args  = [self.input.gateway_id.value]
    }

    card {
      width = 2
      query = query.network_application_gateway_http_listener_count
      args  = [self.input.gateway_id.value]
    }

    card {
      width = 2
      query = query.network_application_gateway_rule_count
      args  = [self.input.gateway_id.value]
    }

    card {
      width = 2
      query = query.network_application_gateway_ssl_cert_count
      args  = [self.input.gateway_id.value]
    }
  }

  with "compute_virtual_machines_for_network_application_gateway" {
    query = query.compute_virtual_machines_for_network_application_gateway
    args  = [self.input.gateway_id.value]
  }

  with "compute_virtual_machine_scale_sets_for_network_application_gateway" {
    query = query.compute_virtual_machine_scale_sets_for_network_application_gateway
    args  = [self.input.gateway_id.value]
  }

  with "network_public_ips_for_network_application_gateway" {
    query = query.network_public_ips_for_network_application_gateway
    args  = [self.input.gateway_id.value]
  }

  with "network_subnets_for_network_application_gateway" {
    query = query.network_subnets_for_network_application_gateway
    args  = [self.input.gateway_id.value]
  }

  with "network_virtual_networks_for_network_application_gateway" {
    query = query.network_virtual_networks_for_network_application_gateway
    args  = [self.input.gateway_id.value]
  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.compute_virtual_machine
        args = {
          compute_virtual_machine_ids = with.compute_virtual_machines_for_network_application_gateway.rows[*].vm_id
        }
      }

      node {
        base = node.compute_virtual_machine_scale_set
        args = {
          compute_virtual_machine_scale_set_ids = with.compute_virtual_machine_scale_sets_for_network_application_gateway.rows[*].vmss_id
        }
      }

      node {
        base = node.network_application_gateway
        args = {
          network_application_gateway_ids = [self.input.gateway_id.value]
        }
      }

      node {
        base = node.network_public_ip
        args = {
          network_public_ip_ids = with.network_public_ips_for_network_application_gateway.rows[*].public_ip_id
        }
      }

      node {
        base = node.network_subnet
        args = {
          network_subnet_ids = with.network_subnets_for_network_application_gateway.rows[*].subnet_id
        }
      }

      node {
        base = node.network_virtual_network
        args = {
          network_virtual_network_ids = with.network_virtual_networks_for_network_application_gateway.rows[*].virtual_network_id
        }
      }

      edge {
        base = edge.network_application_gateway_to_compute_virtual_machine
        args = {
          network_application_gateway_ids = [self.input.gateway_id.value]
        }
      }

      edge {
        base = edge.network_application_gateway_to_compute_virtual_machine_scale_set
        args = {
          network_application_gateway_ids = [self.input.gateway_id.value]
        }
      }

      edge {
        base = edge.network_application_gateway_to_network_public_ip
        args = {
          network_application_gateway_ids = [self.input.gateway_id.value]
        }
      }

      edge {
        base = edge.network_application_gateway_to_network_subnet
        args = {
          network_application_gateway_ids = [self.input.gateway_id.value]
        }
      }

      edge {
        base = edge.network_subnet_to_network_virtual_network
        args = {
          network_subnet_ids = with.network_subnets_for_network_application_gateway.rows[*].subnet_id
        }
      }
    }
  }

  container {
    container {
      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.network_application_gateway_overview
        args  = [self.input.gateway_id.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.network_application_gateway_tags
        args  = [self.input.gateway_id.value]
      }
    }

    container {
      width = 6

      table {
        title = "SKU Configuration"
        query = query.network_application_gateway_sku_config
        args  = [self.input.gateway_id.value]
      }

      table {
        title = "SSL Configuration"
        query = query.network_application_gateway_ssl_config
        args  = [self.input.gateway_id.value]
      }
    }
  }

  container {
    width = 12

    table {
      title = "Backend Address Pools"
      query = query.network_application_gateway_backend_pools
      args  = [self.input.gateway_id.value]
    }
  }

  container {
    width = 12

    table {
      title = "Frontend IP Configurations"
      query = query.network_application_gateway_frontend_ip_config
      args  = [self.input.gateway_id.value]
    }
  }

  container {
    width = 12

    table {
      title = "HTTP Listeners"
      query = query.network_application_gateway_http_listeners
      args  = [self.input.gateway_id.value]
    }
  }

  container {
    width = 12

    table {
      title = "Request Routing Rules"
      query = query.network_application_gateway_request_routing_rules
      args  = [self.input.gateway_id.value]
    }
  }
}

# Card Queries

query "network_application_gateway_sku_name" {
  sql = <<-EOQ
    select
      'SKU Name' as label,
      sku_name as value
    from
      azure_application_gateway
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_sku_tier" {
  sql = <<-EOQ
    select
      'SKU Tier' as label,
      sku_tier as value
    from
      azure_application_gateway
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_backend_pool_count" {
  sql = <<-EOQ
    select
      'Backend Pools' as label,
      count(*) as value
    from
      azure_application_gateway,
      jsonb_array_elements(backend_address_pools) as p
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_http_listener_count" {
  sql = <<-EOQ
    select
      'HTTP Listeners' as label,
      count(*) as value
    from
      azure_application_gateway,
      jsonb_array_elements(http_listeners) as l
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_rule_count" {
  sql = <<-EOQ
    select
      'Routing Rules' as label,
      count(*) as value
    from
      azure_application_gateway,
      jsonb_array_elements(request_routing_rules) as r
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_ssl_cert_count" {
  sql = <<-EOQ
    select
      'SSL Certificates' as label,
      count(*) as value
    from
      azure_application_gateway,
      jsonb_array_elements(ssl_certificates) as c
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

# With Queries

query "compute_virtual_machines_for_network_application_gateway" {
  sql = <<-EOQ
    with backend_vms as (
      select
        lower(vm ->> 'id') as vm_id
      from
        azure_application_gateway,
        jsonb_array_elements(backend_address_pools) as p,
        jsonb_array_elements(p -> 'properties' -> 'backendAddresses') as addr,
        jsonb_array_elements_text(
          case jsonb_typeof(addr -> 'virtualMachine')
            when 'array' then (addr -> 'virtualMachine')
            else jsonb_build_array(addr -> 'virtualMachine')
          end
        ) as vm
      where
        lower(id) = $1
        and subscription_id = split_part($1, '/', 3)
    )
    select
      distinct vm_id
    from
      backend_vms;
  EOQ
}

query "compute_virtual_machine_scale_sets_for_network_application_gateway" {
  sql = <<-EOQ
    with backend_vmss as (
      select
        lower(split_part(addr ->> 'fqdn', '.', 1)) as vmss_id
      from
        azure_application_gateway,
        jsonb_array_elements(backend_address_pools) as p,
        jsonb_array_elements(p -> 'properties' -> 'backendAddresses') as addr
      where
        lower(id) = $1
        and subscription_id = split_part($1, '/', 3)
        and addr ->> 'fqdn' like '%.virtualMachineScaleSets.%'
    )
    select
      distinct vmss_id
    from
      backend_vmss;
  EOQ
}

query "network_public_ips_for_network_application_gateway" {
  sql = <<-EOQ
    select
      distinct lower(ip.id) as public_ip_id
    from
      azure_application_gateway as g,
      jsonb_array_elements(frontend_ip_configurations) as f
      left join azure_public_ip as ip on lower(ip.id) = lower(f -> 'properties' -> 'publicIPAddress' ->> 'id')
    where
      lower(g.id) = $1
      and g.subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_subnets_for_network_application_gateway" {
  sql = <<-EOQ
    select
      distinct lower(s.id) as subnet_id
    from
      azure_application_gateway as g,
      jsonb_array_elements(gateway_ip_configurations) as c
      left join azure_subnet as s on lower(s.id) = lower(c -> 'properties' -> 'subnet' ->> 'id')
    where
      lower(g.id) = $1
      and g.subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_virtual_networks_for_network_application_gateway" {
  sql = <<-EOQ
    with subnet_list as (
      select
        distinct lower(s.id) as subnet_id
      from
        azure_application_gateway as g,
        jsonb_array_elements(gateway_ip_configurations) as c
        left join azure_subnet as s on lower(s.id) = lower(c -> 'properties' -> 'subnet' ->> 'id')
      where
        lower(g.id) = $1
        and g.subscription_id = split_part($1, '/', 3)
    )
    select
      distinct lower(vn.id) as virtual_network_id
    from
      azure_virtual_network as vn,
      jsonb_array_elements(subnets) as s
    where
      lower(s ->> 'id') in (select subnet_id from subnet_list);
  EOQ
}

# Table Queries

query "network_application_gateway_input" {
  sql = <<-EOQ
    select
      g.title as label,
      lower(g.id) as value,
      json_build_object(
        'subscription', s.display_name,
        'resource_group', g.resource_group,
        'region', g.region
      ) as tags
    from
      azure_application_gateway as g,
      azure_subscription as s
    where
      lower(g.subscription_id) = lower(s.subscription_id)
    order by
      g.title;
  EOQ
}

query "network_application_gateway_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      operational_state as "Operational State",
      provisioning_state as "Provisioning State",
      region as "Region",
      resource_group as "Resource Group",
      subscription_id as "Subscription ID",
      id as "ID"
    from
      azure_application_gateway
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_tags" {
  sql = <<-EOQ
    select
      tag.key as "Key",
      tag.value as "Value"
    from
      azure_application_gateway,
      jsonb_each_text(tags) as tag
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3)
    order by
      tag.key;
  EOQ
}

query "network_application_gateway_sku_config" {
  sql = <<-EOQ
    select
      sku_name as "SKU Name",
      sku_tier as "SKU Tier",
      sku_capacity as "Capacity Units"
    from
      azure_application_gateway
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_ssl_config" {
  sql = <<-EOQ
    select
      ssl_policy ->> 'policyType' as "Policy Type",
      ssl_policy ->> 'policyName' as "Policy Name",
      ssl_policy ->> 'minProtocolVersion' as "Min Protocol Version"
    from
      azure_application_gateway
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_backend_pools" {
  sql = <<-EOQ
    select
      p ->> 'name' as "Name",
      addr ->> 'fqdn' as "FQDN",
      addr ->> 'ipAddress' as "IP Address",
      p -> 'properties' ->> 'provisioningState' as "Provisioning State"
    from
      azure_application_gateway,
      jsonb_array_elements(backend_address_pools) as p,
      jsonb_array_elements(p -> 'properties' -> 'backendAddresses') as addr
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_frontend_ip_config" {
  sql = <<-EOQ
    select
      f ->> 'name' as "Name",
      f -> 'properties' ->> 'privateIPAddress' as "Private IP",
      f -> 'properties' -> 'publicIPAddress' ->> 'id' as "Public IP ID",
      f -> 'properties' ->> 'provisioningState' as "Provisioning State"
    from
      azure_application_gateway,
      jsonb_array_elements(frontend_ip_configurations) as f
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_http_listeners" {
  sql = <<-EOQ
    select
      l ->> 'name' as "Name",
      l -> 'properties' ->> 'protocol' as "Protocol",
      l -> 'properties' ->> 'hostName' as "Host Name",
      l -> 'properties' ->> 'requireServerNameIndication' as "Require SNI",
      l -> 'properties' ->> 'provisioningState' as "Provisioning State"
    from
      azure_application_gateway,
      jsonb_array_elements(http_listeners) as l
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
}

query "network_application_gateway_request_routing_rules" {
  sql = <<-EOQ
    select
      r ->> 'name' as "Name",
      r -> 'properties' ->> 'ruleType' as "Rule Type",
      r -> 'properties' ->> 'priority' as "Priority",
      r -> 'properties' ->> 'provisioningState' as "Provisioning State"
    from
      azure_application_gateway,
      jsonb_array_elements(request_routing_rules) as r
    where
      lower(id) = $1
      and subscription_id = split_part($1, '/', 3);
  EOQ
} 