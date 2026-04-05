import styles from "./App.module.css";
import { useApexChessDashboardController } from "./hooks/generated/apex-hooks";
import useSubscribe from "./hooks/useSubscribe";

import React, { useEffect, useState, useMemo } from "react";
import { Container, Text, Title, TextInput, NativeSelect, Card, Badge, Loader, Alert, Stack, Group, Grid, Anchor } from "@mantine/core";
import { Search, AlertCircle } from "lucide-react";
import type { AppProps } from "./types";

// TypeScript interfaces for Account data
interface Account {
  Id: string;
  Name: string;
  Type: string | null;
  Industry: string | null;
  AnnualRevenue: number | null;
  NumberOfEmployees: number | null;
  Phone: string | null;
  Website: string | null;
  BillingCity: string | null;
  BillingState: string | null;
  OwnerId: string;
}

interface PicklistOption {
  label: string;
  value: string;
}

export default function App({ bridge }: AppProps): JSX.Element {
  // State for search and filters
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedType, setSelectedType] = useState("");
  const [selectedIndustry, setSelectedIndustry] = useState("");

  // Apex controller hooks
  const apexController = useApexChessDashboardController(bridge);

  // Subscribe to data from Apex methods
  const {
    loading: loadingAccounts,
    error: errorAccounts,
    data: accounts = [],
  } = useSubscribe<Account[]>(bridge, "ChessDashboardController.getAccounts");

  const {
    loading: loadingTypes,
    data: accountTypes = [],
  } = useSubscribe<PicklistOption[]>(bridge, "ChessDashboardController.getAccountTypes");

  const {
    loading: loadingIndustries,
    data: accountIndustries = [],
  } = useSubscribe<PicklistOption[]>(bridge, "ChessDashboardController.getAccountIndustries");

  // Fetch data on component mount
  useEffect(() => {
    apexController.getAccounts();
    apexController.getAccountTypes();
    apexController.getAccountIndustries();
  }, [apexController]);

  // Filter and search accounts
  const filteredAccounts = useMemo(() => {
    if (!Array.isArray(accounts)) return [];

    return accounts.filter((account) => {
      // Search filter
      const matchesSearch = searchTerm === "" ||
        (account.Name || "").toLowerCase().includes(searchTerm.toLowerCase());

      // Type filter
      const matchesType = selectedType === "" ||
        account.Type === selectedType;

      // Industry filter
      const matchesIndustry = selectedIndustry === "" ||
        account.Industry === selectedIndustry;

      return matchesSearch && matchesType && matchesIndustry;
    });
  }, [accounts, searchTerm, selectedType, selectedIndustry]);

  // Navigate to Account record
  const handleAccountClick = (accountId: string) => {
    bridge.emit("navigate", {
      type: "standard__recordPage",
      attributes: {
        recordId: accountId,
        objectApiName: "Account",
        actionName: "view",
      },
    });
  };

  // Format currency
  const formatCurrency = (value: number | null | undefined): string => {
    const amount = Number(value);
    if (!Number.isFinite(amount)) return "—";
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount);
  };

  // Format number
  const formatNumber = (value: number | null | undefined): string => {
    const num = Number(value);
    if (!Number.isFinite(num)) return "—";
    return new Intl.NumberFormat("en-US").format(num);
  };

  // Format location
  const formatLocation = (city: string | null, state: string | null): string => {
    if (city && state) return `${city}, ${state}`;
    if (city) return city;
    if (state) return state;
    return "—";
  };

  return (
    <div className={styles.chessboard}>
      {/* Header */}
      <div className={styles.header}>
        <Container size="xl" p="lg">
          <Title order={1} className={styles.title}>
            ♟️ Chess Dashboard
          </Title>
          <Text size="sm" c="dimmed" mt="xs">
            Your accounts displayed in a chess-themed board
          </Text>
        </Container>
      </div>

      {/* Search and Filters */}
      <Container size="xl" p="lg">
        <Card shadow="sm" p="md" radius="md" withBorder className={styles.filterCard}>
          <Grid gutter="md">
            <Grid.Col span={{ base: 12, md: 6 }}>
              <TextInput
                placeholder="Search accounts by name..."
                leftSection={<Search size={16} />}
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.currentTarget.value)}
                size="md"
              />
            </Grid.Col>
            <Grid.Col span={{ base: 12, sm: 6, md: 3 }}>
              <NativeSelect
                data={accountTypes}
                value={selectedType}
                onChange={(e) => setSelectedType(e.currentTarget.value)}
                size="md"
                disabled={loadingTypes}
              />
            </Grid.Col>
            <Grid.Col span={{ base: 12, sm: 6, md: 3 }}>
              <NativeSelect
                data={accountIndustries}
                value={selectedIndustry}
                onChange={(e) => setSelectedIndustry(e.currentTarget.value)}
                size="md"
                disabled={loadingIndustries}
              />
            </Grid.Col>
          </Grid>

          {/* Account count */}
          <Text size="sm" c="dimmed" mt="md">
            Showing {filteredAccounts.length} {filteredAccounts.length === 1 ? "account" : "accounts"}
          </Text>
        </Card>

        {/* Loading State */}
        {loadingAccounts && (
          <Stack align="center" mt="xl" gap="md">
            <Loader size="lg" />
            <Text c="dimmed">Loading your accounts...</Text>
          </Stack>
        )}

        {/* Error State */}
        {errorAccounts && !loadingAccounts && (
          <Alert icon={<AlertCircle size={16} />} title="Error Loading Accounts" color="red" mt="lg">
            {String(errorAccounts)}
          </Alert>
        )}

        {/* Empty State */}
        {!loadingAccounts && !errorAccounts && filteredAccounts.length === 0 && (
          <Card shadow="sm" p="xl" radius="md" withBorder mt="lg" className={styles.emptyState}>
            <Stack align="center" gap="md">
              <Text size="xl" fw={600}>
                No accounts found
              </Text>
              <Text c="dimmed" ta="center">
                {searchTerm || selectedType || selectedIndustry
                  ? "Try adjusting your search or filters"
                  : "You don't have any accounts yet"}
              </Text>
            </Stack>
          </Card>
        )}

        {/* Account Cards Grid */}
        {!loadingAccounts && !errorAccounts && filteredAccounts.length > 0 && (
          <Grid gutter="md" mt="lg">
            {filteredAccounts.map((account, index) => {
              const isLight = index % 2 === 0;
              const cardClass = isLight ? styles.cardLight : styles.cardDark;

              return (
                <Grid.Col key={account.Id} span={{ base: 12, sm: 6, lg: 4 }}>
                  <Card
                    shadow="sm"
                    p="lg"
                    radius="md"
                    withBorder
                    className={`${styles.accountCard} ${cardClass}`}
                    onClick={() => handleAccountClick(account.Id)}
                    style={{ cursor: "pointer" }}
                  >
                    <Stack gap="sm">
                      {/* Account Name */}
                      <Group justify="space-between" wrap="nowrap">
                        <Text fw={700} size="lg" lineClamp={1} className={styles.accountName}>
                          {account.Name}
                        </Text>
                      </Group>

                      {/* Type and Industry Badges */}
                      <Group gap="xs">
                        {account.Type && (
                          <Badge variant="light" color="blue" size="sm">
                            {account.Type}
                          </Badge>
                        )}
                        {account.Industry && (
                          <Badge variant="light" color="grape" size="sm">
                            {account.Industry}
                          </Badge>
                        )}
                      </Group>

                      {/* Account Details */}
                      <Stack gap="xs" className={styles.accountDetails}>
                        {account.AnnualRevenue !== null && (
                          <Group gap="xs">
                            <Text size="xs" c="dimmed" fw={600}>
                              Revenue:
                            </Text>
                            <Text size="xs">{formatCurrency(account.AnnualRevenue)}</Text>
                          </Group>
                        )}

                        {account.NumberOfEmployees !== null && (
                          <Group gap="xs">
                            <Text size="xs" c="dimmed" fw={600}>
                              Employees:
                            </Text>
                            <Text size="xs">{formatNumber(account.NumberOfEmployees)}</Text>
                          </Group>
                        )}

                        {account.Phone && (
                          <Group gap="xs">
                            <Text size="xs" c="dimmed" fw={600}>
                              Phone:
                            </Text>
                            <Text size="xs">{account.Phone}</Text>
                          </Group>
                        )}

                        {account.Website && (
                          <Group gap="xs">
                            <Text size="xs" c="dimmed" fw={600}>
                              Website:
                            </Text>
                            <Anchor
                              size="xs"
                              href={`https://${account.Website.replace(/^https?:\/\//, "")}`}
                              target="_blank"
                              rel="noopener noreferrer"
                              onClick={(e) => e.stopPropagation()}
                            >
                              {account.Website}
                            </Anchor>
                          </Group>
                        )}

                        {(account.BillingCity || account.BillingState) && (
                          <Group gap="xs">
                            <Text size="xs" c="dimmed" fw={600}>
                              Location:
                            </Text>
                            <Text size="xs">
                              {formatLocation(account.BillingCity, account.BillingState)}
                            </Text>
                          </Group>
                        )}
                      </Stack>
                    </Stack>
                  </Card>
                </Grid.Col>
              );
            })}
          </Grid>
        )}
      </Container>
    </div>
  );
}
