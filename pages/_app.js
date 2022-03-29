import React from "react";
import { MantineProvider } from "@mantine/core";
import { QueryClientProvider, QueryClient } from "react-query";
import "../styles/globals.css";

const MyApp = (props) => {
  const { Component, pageProps } = props;

  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        refetchOnWindowFocus: false,
      },
    },
  });

  return (
    <MantineProvider withGlobalStyles withNormalizeCSS>
      <QueryClientProvider client={queryClient}>
        <Component {...pageProps} />
      </QueryClientProvider>
    </MantineProvider>
  );
};

export default MyApp;
